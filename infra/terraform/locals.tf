locals {
  name_prefix = replace(lower("${var.project_name}-${var.environment}"), "/[^a-z0-9-]/", "-")

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count,
  )

  public_subnet_cidrs = [
    for index, _ in local.availability_zones :
    cidrsubnet(var.vpc_cidr, 4, index)
  ]

  private_app_subnet_cidrs = [
    for index, _ in local.availability_zones :
    cidrsubnet(var.vpc_cidr, 4, index + 4)
  ]

  private_db_subnet_cidrs = [
    for index, _ in local.availability_zones :
    cidrsubnet(var.vpc_cidr, 4, index + 8)
  ]

  tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
