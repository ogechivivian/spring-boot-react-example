output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "frontend_bucket_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}