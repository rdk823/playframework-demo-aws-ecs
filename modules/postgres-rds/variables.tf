variable "project" {
  description = "The project"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

//variable "allowed_security_group_id" {
//  description = "The allowed security group id to connect on RDS"
//}

variable "allocated_storage" {
  description = "The storage size in GB"
  type        = string
  default     = "20"
}

variable "instance_class" {
  description = "The instance type"
  type        = string
}

variable "multi_az" {
  description = "Muti-az allowed?"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "The database name"
  type        = string
}
