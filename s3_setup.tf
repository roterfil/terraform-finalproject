resource "aws_s3_bucket" "tf_state" {
  bucket = "borromeo-tf-state-bucket"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform-State-Bucket"
    Engineer    = "Borromeo-Clareene"
    ProjectCode = "Terraform101-CloudIntern"
  }
}

resource "aws_s3_bucket_versioning" "ver" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}