variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
}

variable "vpc_subnet_cidr" {
  description = "The subnet CIDR block of the vpc"
  type = list(object({
    availablity_zone    = string
    public_subnet_cidr  = string
    private_subnet_cidr = string
  }))
}

variable "project" {
  description = "The project"
  type        = string
}