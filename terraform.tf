terraform {
    required_version = ">=0.13.4"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "3.9.0"
        }
        random = {
            source = "hashicorp/random"
            version = "2.3.0"
        }
    }
}