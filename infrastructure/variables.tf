
variable "app_name" {
  type = string
  description = "Application name used for resource naming"
  default = "todo-app"
}
variable "cluster_ready" {
  type = string
}
variable "app_replicas" {
  type        = number
  description = "Number of application replicas"
  default     = 3  # Default number of pods
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "change-me-123"
}

variable "redis_password" {
  type      = string
  sensitive = true
  default   = "redis-pass-123"
}