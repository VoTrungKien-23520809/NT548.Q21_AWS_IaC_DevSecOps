output "public_instance_ip" {
  value       = aws_instance.public_ec2.public_ip
  description = "IP Public cua máy dùng de SSH"
}

output "private_instance_ip" {
  value       = aws_instance.private_ec2.private_ip
  description = "IP Noi bo cua máy Private"
}
