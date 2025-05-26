provider "aws" {
    region = "us-east-1"
  }
  
  resource "aws_key_pair" "deployer" {
    key_name   = "cloudshell-key"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
  data "aws_vpc" "selected" {
    default = true
  }
  
  data "aws_subnets" "selected" {
    filter {
      name   = "vpc-id"
      values = [data.aws_vpc.selected.id]
    }
  }
  
  resource "aws_security_group" "ec2_sg" {
    name        = "ec2-allow-ssh-mysql"
    description = "Allow SSH and MySQL out"
    vpc_id      = data.aws_vpc.selected.id
  
    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  resource "aws_instance" "ec2_rds_client" {
    ami                         = "ami-084568db4383264d4"  # Ubuntu Server 24.04 LTS
    instance_type               = "t2.micro"
    subnet_id                   = data.aws_subnet.selected.id  # Asegúrate que esté bien referenciado
    vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
    key_name                    = aws_key_pair.deployer.key_name
    associate_public_ip_address = true
  
    provisioner "remote-exec" {
      inline = [
        "sudo apt update",
        "sudo apt install -y mysql-client"
      ]
  
      connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/id_rsa")
        host        = self.public_ip
      }
    }
  }
  