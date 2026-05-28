# NT548 - CÔNG NGHỆ DEVOPS VÀ ỨNG DỤNG (UIT)

## BÀI TẬP THỰC HÀNH 01

# Quản lý và triển khai hạ tầng AWS bằng Terraform

---

## 📚 Thông tin môn học

- **Môn học:** Công nghệ DevOps và Ứng dụng
- **Mã môn học:** NT548
- **Giảng viên hướng dẫn:** ThS. Lê Anh Tuấn
- **Môi trường triển khai:** AWS Learner Lab
- **Cloud Provider:** Amazon Web Services (AWS)
- **IaC Tool:** Terraform
- **Region mặc định:** `us-east-1`

---

# 👥 Thành viên thực hiện

| Họ và tên            | MSSV     | Vai trò                             |
| -------------------- | -------- | ----------------------------------- |
| Nguyễn Minh Quyên    | 23521325 | Deployment / Run test case          |
| Bùi Đặng Nhật Nguyên | 23521037 | Terraform module VPC / Write report |
| Võ Trung Kiên        | 23520809 | Terraform module EC2                |
| Ngô Trọng Quyền      | 23521324 | Terraform main                      |

---

# 🎯 Mục tiêu bài thực hành

Bài thực hành nhằm mục tiêu:

- Làm quen với mô hình **Infrastructure as Code (IaC)**.
- Triển khai hạ tầng AWS tự động bằng Terraform.
- Thiết lập hệ thống mạng riêng trên AWS sử dụng:
  - VPC
  - Public Subnet
  - Private Subnet
  - Internet Gateway
  - NAT Gateway
  - Route Table
- Tạo và quản lý EC2 Instances.
- Thiết lập Security Groups nhằm kiểm soát truy cập mạng.
- Kiểm thử khả năng:
  - SSH vào Public EC2
  - Bastion Host truy cập Private EC2
  - Private EC2 truy cập Internet thông qua NAT Gateway
  - Cô lập Private EC2 khỏi Internet công cộng

---

# 🏗️ Kiến trúc hệ thống

## Mô hình triển khai

<div align="center">

![System Architecture](docs/images/[NT548]ARCHITECTURE_DIAGRAM.png?v=3)
*Sơ đồ Kiến trúc hệ thống*
</div>

---

# 📁 Cấu trúc thư mục dự án

<div align="center">

<img src="docs/images/%5BNT548%5Dfolder_architecture.png?v=999" width="33%">

<br>
<i>Sơ đồ cấu trúc thư mục dự án</i>

</div>

---

# 🛠️ Yêu cầu môi trường

## 1. Terraform CLI

- Terraform version khuyến nghị: `>= 1.7.0`

### Kiểm tra phiên bản

```bash
terraform -version
```

---

## 2. AWS Learner Lab

Yêu cầu:

- Có tài khoản AWS Academy Learner Lab
- Đã Start Lab thành công
- Có quyền sử dụng:
  - EC2
  - VPC
  - Security Group
  - Route Table
  - Elastic IP
  - NAT Gateway

---

## 3. OpenSSH Client

Dùng để:

- SSH vào EC2
- Thực hiện Bastion Jump
- Forward SSH Agent

### Kiểm tra SSH

```bash
ssh -V
```

---

# ⚙️ Cài đặt Terraform

## Ubuntu / Linux

```bash
wget -O- https://apt.releases.hashicorp.com/gpg \
| sudo gpg --dearmor \
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg


echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
```

---

## Windows

Tải trực tiếp tại:

- https://developer.hashicorp.com/terraform/downloads

Sau khi cài đặt:

```powershell
terraform -version
```

---

## macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

---

# 🚀 Hướng dẫn triển khai hệ thống

## Bước 1: Clone source code

```bash
git clone https://github.com/Minh-Quyen-uit/NT548.Q21_AWS_IaC_DevSecOps.git
cd NT548.Q21_AWS_IaC_DevSecOps
```

---

## Bước 2: Khởi tạo Terraform

```bash
terraform init
```

Terraform sẽ tự động:

- Tải AWS Provider
- Tải các modules cần thiết
- Tạo thư mục `.terraform`

---

## Bước 3: Xem trước kế hoạch triển khai

```bash
terraform plan
```

Terraform sẽ hiển thị:

- Các tài nguyên sẽ được tạo
- Các subnet
- Security Groups
- EC2 Instances
- NAT Gateway
- Route Tables

---

## Bước 4: Deploy hạ tầng

```bash
terraform apply -auto-approve
```

Thời gian triển khai:

- Khoảng 2–5 phút

Sau khi hoàn tất:

Terraform sẽ xuất:

```text
Outputs:

public_instance_ip = "x.x.x.x"
private_instance_ip = "x.x.x.x"
```

Đồng thời sinh file:

```text
dev-deployer-key.pem
```

---

# 🔑 Cấu hình file PEM

## Linux/macOS

```bash
chmod 400 dev-deployer-key.pem
```

---

## Windows PowerShell

Có thể dùng Git Bash hoặc WSL để SSH.

---

# 🧪 Test Cases

---

# ✅ Test Case 1 — SSH vào Public EC2

## Mục tiêu

Kiểm tra:

- Public EC2 có Public IP
- Security Group mở cổng 22
- Có thể SSH từ Internet

---

## Thực hiện

```bash
ssh -i dev-deployer-key.pem ubuntu@<PUBLIC_SERVER_IP>
```

---

## Kết quả mong đợi

SSH thành công:

```text
ubuntu@ip-10-0-x-x:~$
```

---

# ✅ Test Case 2 — Bastion Jump sang Private EC2

## Mục tiêu

Kiểm tra:

- Public EC2 hoạt động như Bastion Host
- Private EC2 chỉ cho phép SSH nội bộ
- SSH Agent Forwarding hoạt động đúng

---

## Bước 1: Khởi động SSH Agent

```bash
eval $(ssh-agent -s)
```

---

## Bước 2: Add PEM key

```bash
ssh-add dev-deployer-key.pem
```

---

## Bước 3: SSH vào Bastion Host

```bash
ssh -A ubuntu@<PUBLIC_SERVER_IP>
```

---

## Bước 4: SSH vào Private EC2

```bash
ssh ubuntu@<PRIVATE_SERVER_IP>
```

---

## Kết quả mong đợi

SSH thành công vào Private EC2.

---

# ✅ Test Case 3 — Private EC2 truy cập Internet thông qua NAT Gateway

## Mục tiêu

Kiểm tra:

- Private EC2 không có Public IP
- Có outbound Internet thông qua NAT Gateway

---

## Thực hiện

Từ Private EC2:

```bash
curl -I https://www.google.com
```

---

## Kết quả mong đợi

```text
HTTP/2 200
```

Điều này chứng minh:

- NAT Gateway hoạt động chính xác
- Private subnet có outbound Internet

---

# ✅ Test Case 4 — Kiểm tra tính cô lập của Private EC2

## Mục tiêu

Đảm bảo:

- Không thể SSH trực tiếp từ Internet vào Private EC2

---

## Thực hiện

Từ máy local:

```bash
ssh -i dev-deployer-key.pem ubuntu@<PRIVATE_SERVER_IP>
```

---

## Kết quả mong đợi

```text
Connection timed out
```

hoặc:

```text
Connection refused
```

Điều này chứng minh:

- Private subnet đã được cô lập đúng thiết kế
- Security Group hoạt động chính xác

---

# 🔒 Security Configuration

## Public EC2 Security Group

Cho phép:

| Protocol | Port | Source   |
| -------- | ---- | -------- |
| TCP      | 22   | Internet |

---

## Private EC2 Security Group

Cho phép:

| Protocol | Port | Source                    |
| -------- | ---- | ------------------------- |
| TCP      | 22   | Public EC2 Security Group |

---

# 📤 Terraform Outputs

Ví dụ:

```text
Outputs:

public_instance_ip = "54.xxx.xxx.xxx"
private_instance_ip = "10.0.2.xxx"
```

---

# 🧹 Hủy toàn bộ hạ tầng

Sau khi hoàn tất bài thực hành:

```bash
terraform destroy -auto-approve
```

Terraform sẽ tự động:

- Xóa EC2 Instances
- Xóa NAT Gateway
- Xóa Route Tables
- Xóa Security Groups
- Xóa toàn bộ hạ tầng AWS

---

# ⚠️ Lưu ý quan trọng

## AWS Learner Lab Credentials

Credentials của AWS Learner Lab:

- Có thời hạn tạm thời
- Sẽ thay đổi khi Stop/Start Lab
- Cần export lại mỗi lần Lab reset

---

## NAT Gateway Cost

NAT Gateway có thể phát sinh chi phí nếu dùng AWS cá nhân.

Khuyến nghị:

```bash
terraform destroy -auto-approve
```

sau khi hoàn tất bài thực hành.

---

# 📖 Kiến thức đạt được

Thông qua bài thực hành, nhóm đã:

- Làm quen Terraform IaC
- Thiết kế AWS Networking
- Hiểu Public vs Private Subnet
- Triển khai NAT Gateway
- Cấu hình Security Groups
- Thực hiện Bastion Host Architecture
- Kiểm thử SSH Security
- Quản lý hạ tầng tự động bằng Terraform

---

# 📌 Công nghệ sử dụng

| Công nghệ       | Mục đích                           |
| --------------- | ---------------------------------- |
| Terraform       | Infrastructure as Code             |
| AWS EC2         | Virtual Machine                    |
| AWS VPC         | Networking                         |
| NAT Gateway     | Internet Access for Private Subnet |
| Security Group  | Firewall                           |
| OpenSSH         | Remote Access                      |
| AWS Learner Lab | Cloud Environment                  |

---

# ✅ Kết luận

Bài thực hành đã triển khai thành công một hệ thống hạ tầng AWS hoàn chỉnh bằng Terraform với:

- Public và Private Subnet
- Bastion Host
- NAT Gateway
- Security Groups
- SSH Secure Access

Hệ thống đảm bảo:

- Truy cập quản trị an toàn
- Cô lập tài nguyên nội bộ
- Cho phép outbound Internet đúng thiết kế
- Triển khai hoàn toàn tự động bằng Infrastructure as Code

---

# 📬 Liên hệ

Nếu có vấn đề trong quá trình triển khai:

- Kiểm tra lại AWS Credentials
- Kiểm tra Terraform version
- Kiểm tra Region AWS
- Kiểm tra Security Group Rules
- Kiểm tra Route Tables và NAT Gateway

---

⭐ NT548 - Công nghệ DevOps và Ứng dụng ⭐

