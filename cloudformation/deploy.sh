#!/bin/bash
set -e

STACK_NAME="NT548-Lab2-Infra"
TEMPLATE="cloudformation/infrastructure.yaml"
REGION="us-east-1"
KEY_NAME="vockey"

echo "================================================"
echo " NT548 Lab2 - CloudFormation Deploy Pipeline"
echo "================================================"

# Stage 1: Lint
echo ""
echo "[STAGE 1] Running cfn-lint..."
cfn-lint $TEMPLATE -i W
echo "✅ cfn-lint PASSED"

# Stage 2: Check stack status
echo ""
echo "[STAGE 2] Checking existing stack..."
STACK_STATUS=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].StackStatus' \
  --output text 2>/dev/null || echo "DOES_NOT_EXIST")

echo "   Stack status: $STACK_STATUS"

# Stage 3: Deploy
echo ""
echo "[STAGE 3] Deploying CloudFormation stack..."

if [ "$STACK_STATUS" == "DOES_NOT_EXIST" ]; then
  echo "   Creating new stack..."
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE \
    --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
else
  echo "   Updating existing stack..."
  aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE \
    --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION 2>/dev/null || echo "   No updates needed."
fi

# Stage 4: Wait
echo ""
echo "[STAGE 4] Waiting for stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME \
  --region $REGION 2>/dev/null || \
aws cloudformation wait stack-update-complete \
  --stack-name $STACK_NAME \
  --region $REGION 2>/dev/null || true

# Stage 5: Output
echo ""
echo "[STAGE 5] Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs' \
  --output table

echo ""
echo "✅ Pipeline completed successfully!"
