variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION"{
    default = "us-east-2"
}
variable "AWS_AMI" {
    type = map
    default = {
        "us-east-1" = "ami-085925f297f89fce1"
        "us-east-2" = "ami-0d97ef13c06b05a19"
    }
}

