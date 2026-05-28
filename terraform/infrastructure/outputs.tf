output "public_server_ip" {
  value = module.ec2.public_instance_ip
}

output "private_server_ip" {
  value = module.ec2.private_instance_ip
}
