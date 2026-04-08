
############################
# Provider Detials
############################
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}
terraform {
  backend "s3" {
    bucket         = "myterraformstatebuckettrend"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
############################
# VPC + Networking (us-east-1)
############################
resource "aws_vpc" "vpc_use1" {
  provider   = aws.east
  cidr_block = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
}

resource "aws_internet_gateway" "igw_use1" {
  provider = aws.east
  vpc_id   = aws_vpc.vpc_use1.id
}

resource "aws_subnet" "subnet_use1" {
  provider          = aws.east
  vpc_id            = aws_vpc.vpc_use1.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt_use1" {
  provider = aws.east
  vpc_id   = aws_vpc.vpc_use1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_use1.id
  }
}

resource "aws_route_table_association" "rta_use1" {
  provider       = aws.east
  subnet_id      = aws_subnet.subnet_use1.id
  route_table_id = aws_route_table.rt_use1.id
}

resource "aws_security_group" "sg_use1" {
  provider    = aws.east
  vpc_id      = aws_vpc.vpc_use1.id
  name        = "allow_ssh_http_use1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.204.131.39/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 8080
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
############################
# User Data Script
############################
locals {
Jenkins_installation = <<-EOF
            #!/bin/bash
            sudo yum update –y
            sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
            sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
            sudo yum upgrade
            sudo yum install java-21-amazon-corretto -y
            sudo yum install jenkins -y
            sudo systemctl enable jenkins
            sudo systemctl start jenkins
            sudo yum install git -y
            sudo yum install docker -y 
            sudo systemctl enable docker 
            sudo systemctl start docker 
            sudo usermod -aG docker jenkins
            sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin/kubectl
            sudo wget https://get.helm.sh/helm-v3.15.1-linux-amd64.tar.gz
            sudo tar -zxvf helm-v3.15.1-linux-amd64.tar.gz
            sudo mv linux-amd64/helm /usr/local/bin/helm
            helm version
            EOF
}
############################
# EC2 Instances
############################
resource "aws_instance" "ec2_use1" {
provider          = aws.east
ami               = "ami-02dfbd4ff395f2a1b"
instance_type     = "t2.medium"
subnet_id         = aws_subnet.subnet_use1.id
vpc_security_group_ids = [aws_security_group.sg_use1.id]
user_data         = local.Jenkins_installation
key_name          = "testing"
tags = {
  "Name" = "Jenkins-Server"
}
}
############################
# Instance Output details
############################

output "use1_public_ip" {
  value = aws_instance.ec2_use1.public_ip
}