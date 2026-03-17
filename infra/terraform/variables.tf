variable "aws_region" {
  description = "AWS region for the main stack."
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "todo-sample"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "github_repository" {
  description = "GitHub repository in owner/name format allowed to assume the deployment role."
  type        = string
  default     = "matthewTechCom/todo_sample"
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the deployment role."
  type        = string
  default     = "main"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_count" {
  description = "Number of availability zones to use."
  type        = number
  default     = 2
}

variable "backend_container_port" {
  description = "Port exposed by the Rails container."
  type        = number
  default     = 3000
}

variable "backend_cpu" {
  description = "Fargate CPU units for the backend task."
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Fargate memory in MiB for the backend task."
  type        = number
  default     = 512
}

variable "backend_cpu_architecture" {
  description = "CPU architecture for the backend ECS task."
  type        = string
  default     = "ARM64"

  validation {
    condition     = contains(["ARM64", "X86_64"], var.backend_cpu_architecture)
    error_message = "backend_cpu_architecture must be ARM64 or X86_64."
  }
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks."
  type        = number
  default     = 1
}

variable "backend_image_tag" {
  description = "Container image tag to deploy from ECR."
  type        = string
  default     = "latest"
}

variable "backend_health_check_path" {
  description = "Health check path for the Rails app."
  type        = string
  default     = "/up"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for frontend and backend distributions."
  type        = string
  default     = "PriceClass_200"
}

variable "frontend_bucket_force_destroy" {
  description = "Whether to allow Terraform to delete the frontend S3 bucket with objects."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "RDS database name."
  type        = string
  default     = "backend_production"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "backend"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB for RDS."
  type        = number
  default     = 20
}

variable "db_backup_retention_days" {
  description = "Automated backup retention period."
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ for RDS."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
