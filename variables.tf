variable "vpc_cidr_block" {
  description = "VPC cidr block"
}

variable "vpc_subnet_block" {
  description = "VPC subnet block"
}

variable "region" {
  description = "AWS region"
}

variable "project" {
  description = "The application project"
}

variable "application_name" {
  description = "The name of docker application"
}

variable "container_port" {
  description = "The application container port"
}

variable "acm_cert_domain" {
  description = "The domain name used in AWS Certificate Manager"
}

variable "min_capacity" {
  description = "Mininum number of nodes"
}

variable "max_capacity" {
  description = "Maximum number of nodes"
}

variable "image_tag" {
  description = "The docker image tag to be deployed in ecs"
}

variable "log_retention_in_days" {
  description = "No of days to retain logs"
}