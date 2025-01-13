variable "db_password" {
  description = "RDS password"
  sensitive   = true
  default     =  "Apprdspass"
}
variable "aws_region" {
  default = "eu-west-1"
}