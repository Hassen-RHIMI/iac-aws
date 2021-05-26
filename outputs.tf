output "public_ip"{
    value = aws_instance.ec2_instance.public_ip
}
output "website_endpoint"{
    description = "Domain name of the bucket"
    value = module.website_s3_bucket
}