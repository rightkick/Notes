# Use a specific AWS profile
provider "aws" {
  region  = "us-east-1"
  profile = "LabUserAccess-338065306366"
}

# Define the EC2 instance details
resource "aws_instance" "myvm" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"

  tags = {
    Name = "my-test-vm"
  }

  user_data = <<EOF
    #!/bin/bash
    sudo apt update
    sudo apt install nginx -y
    sudo systemctl enable nginx --now
    EOF

  key_name = aws_key_pair.alexk-ssh-pub-key.id
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]

}

# Define the SSH pub key
resource "aws_key_pair" "alexk-ssh-pub-key" {
    public_key = file("keys/id_ed25519.pub")
}

# Define the security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.aws_vpc_id

  tags = {
    Name = "allow_ssh"
  }
}

# Define ingress and egress rules
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Print the public IP of the provisioned VM
output publicip {
  value       = aws_instance.myvm.public_ip
}

