resource "aws_s3_bucket" "bucket" {
  bucket = var.bucketname
  acl    = "private"

  provisioner "local-exec" {
    command = "sleep 20"
    interpreter = ["/bin/bash", "-c"]
  }
  tags = {
    Name        = var.bucketname
    Project     = var.project
    Creator     = var.creator
    Environment = var.env
    Terraform   = var.terraform
  }
}