variable "project" {
  description = "The project"
  type        = string
}

variable "application_name" {
  description = "Application Name"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = string
}

variable "acm_cert_domain" {
  description = "The domain name used in AWS Certificate Manager"
  type        = string
}

variable "min_capacity" {
  description = "Mininum number of nodes"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of nodes"
  type        = number
}

variable "region" {
  type        = string
}

variable "image_tag" {
  type        = string
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "security_groups_ids" {
  description = "The SGs to use"
  type        = any
}

variable "subnets_ids" {
  description = "The private subnets to use"
  type        = list
}

variable "public_subnet_ids" {
  description = "The public subnets to use"
  type        = list
}

variable "repository_name" {
  description = "The name of the repisitory"
  type        = string
}

variable "log_retention_in_days" {
  description = "No of days to retain logs"
  type        = string
}