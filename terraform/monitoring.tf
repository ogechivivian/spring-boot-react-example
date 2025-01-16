resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/cluster-logs/${module.eks.cluster_name}"
  retention_in_days = 1
}


# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   namespace  = "monitoring"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#
#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }
# }