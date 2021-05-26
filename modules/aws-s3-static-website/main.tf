resource "aws_s3_bucket" "website_bucket"{
    bucket = var.bucket_name
    acl = "public-read"
    policy = file("policy.json")
    website {
        index_document = "main.html"
        error_document = "error.html"
    }
}