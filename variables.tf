variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "VPC cidr block"
  default     = "10.0.0.0/16"
}

variable "vpc_subnet_block" {
  description = "VPC subnet block"
  default = [
    {
        availablity_zone    = "us-east-1a"
        public_subnet_cidr  = "10.0.1.0/24"
        private_subnet_cidr = "10.0.10.0/24"
    },
    {
        availablity_zone    = "us-east-1b"
        public_subnet_cidr  = "10.0.2.0/24"
        private_subnet_cidr = "10.0.20.0/24"
    }
  ]
}

variable "project" {
  description = "The application project"
  default     = "fettch"
}

variable "application_name" {
  description = "The name of docker application"
  default     = "playframework-demo"
}

variable "container_port" {
  description = "The application container port"
  default     = "9000"
}

variable "acm_cert_domain" {
  description = "The domain name used in AWS Certificate Manager"
  default     = "cfdomain.ga"
}

variable "min_capacity" {
  description = "Mininum number of nodes"
  default    = 180
}