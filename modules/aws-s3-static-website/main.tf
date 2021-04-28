resource "aws_s3_bucket" "website_bucket"{
    bucket = var.website_bucket_name
    acl = "public-read"
    policy = <<EOF 
    {
    "Version": "1.0",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.website_bucket_name}/*"
            ]
        }
    ]
}

    EOF
    website {
        index_document = "main.html"
        error_document = "error.html"
    }
}