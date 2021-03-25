terraform {
    backend "s3"{
        bucket = "terraform-bucket-aws-s3"
        key = "states/terraform.state"
        region = "us-east-2"
    }
}
provider "aws" {
    region = var.AWS_REGION
    # Set Authentification keys on aws cli configuration 
    # access_key = var.AWS_ACCESS_KEY
    # secret_key = var.AWS_SECRET_KEY
 }
 
 resource "aws_key_pair" "dev01_ec2_vm01_key" {
         key_name = "terraform-key"
         public_key = file("${path.module}/ssh_users_public_keys/terraform.pub")
 }

resource "aws_security_group" "instance_sg"{
    name = "terraform-test-sg"

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
}

resource "aws_instance" "dev01_ec2_vm01" {
    ami = var.AWS_AMI[var.AWS_REGION]
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name = aws_key_pair.dev01_ec2_vm01_key.key_name

    connection {
        type = "ssh"
        user = "centos"
        private_key = file("${path.module}/ssh_users_private_keys/terraform")
        host = self.public_ip
    }
    tags = {
        Name = terraform.workspace == "qual" ? "qual01_ec2_vm01" : "dev01_ec2_vm01"
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
          "sudo sh -c 'echo \"<h1>Mon adresse ip est ${aws_instance.dev01_ec2_vm01.public_ip}</h1>\" > /var/www/html/index.html'",
        ]
   }
   provisioner "remote-exec" {
         inline = ["sudo sh /tmp/ssh_user_accounts.sh"]
         on_failure = continue
   }
 
}

output "public_ip"{
    value = aws_instance.dev01_ec2_vm01.public_ip
}



