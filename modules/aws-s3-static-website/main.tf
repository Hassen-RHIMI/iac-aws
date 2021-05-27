resource "aws_s3_bucket" "website_bucket"{
    bucket = var.bucket_name
    acl = "public-read"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
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