resource "aws_cloudtrail" "eks_trail" {
  name                          = "eks-audit-trail"
  s3_bucket_name                = aws_s3_bucket.eks_audit_bucket.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}

resource "aws_s3_bucket" "eks_audit_bucket" {
  bucket = "eks-audit-logs-${random_id.suffix.hex}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 90
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 8
}
