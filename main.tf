terraform {
    backend "s3"{
        bucket = "terraform-bucket-aws-s3"
        key = "states/terraform.state"
        region = "us-east-2"
    }
}
provider "aws" {
    region = var.AWS_REGION
 }
locals {
    environment = terraform.workspace == "qual" ? "qual" : "dev"
    key_pair_name = terraform.workspace == "qual" ? "qual-key" : "dev-key"
    sg_name = terraform.workspace == "qual" ? "qual-sg" : "dev-sg"
    instance_name = terraform.workspace == "qual" ? "qual01_ec2_vm01" : "dev01_ec2_vm01"
    
}
data "aws_ami" "centos-ami" {
    most_recent = true
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name   = "name"
        values = ["CentOS Stream 8 x86_64"]
    }
    owners = ["125523088429"]
}
 resource "aws_key_pair" "ec2_key_access" {
         key_name = local.key_pair_name
         public_key = file("${path.module}/ssh_users_public_keys/terraform.pub")
         tags = {
             env = local.environment
         }   
 }

resource "aws_security_group" "instance_sg"{
    name = local.sg_name

    egress {
         from_port = 0
         to_port = 0 
         protocol = "-1"
         cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks =["91.173.75.183/32"]

    }
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["91.173.75.183/32"]
    }
    tags = {
             env = local.environment
         }
}

resource "aws_instance" "ec2_instance" {
    ami = data.aws_ami.centos-ami.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name = aws_key_pair.ec2_key_access.key_name

    connection {
        type = "ssh"
        user = "centos"
      //  private_key = file("${path.module}/ssh_users_private_keys/terraform")
        host = self.public_ip
        agent = true
    }
    tags = {
        Name = local.instance_name
    }
   provisioner "file" {
        source = "${path.module}/ssh_users_public_keys/"
        destination = "/tmp"
   }
    provisioner "file" {
        source = "${path.module}/ssh_user_accounts.sh"
        destination = "/tmp/ssh_user_accounts.sh"
   }
   provisioner "remote-exec" {
          inline = [
          "sudo yum -y update",
          "sudo yum -y install httpd",
          "sudo systemctl start httpd",
          "sudo systemctl enable httpd",
          "sudo sh -c 'echo \"<h1>Mon adresse ip est ${aws_instance.ec2_instance.public_ip}</h1>\" > /var/www/html/index.html'",
        ]
   }
   provisioner "remote-exec" {
         inline = ["sudo sh /tmp/ssh_user_accounts.sh"]
         on_failure = continue
   }
 
}

