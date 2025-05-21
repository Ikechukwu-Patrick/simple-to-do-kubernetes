variable "app_name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket for application data"
}

variable "replica_count" {
  type        = number
  description = "Number of pod replicas"
  default     = 2
}

variable "image_version" {
  type        = string
  description = "Docker image version"
  default     = "latest"
}