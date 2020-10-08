#!/bin/sh

# Make the script to abort if any command fails
set -e

# Print the commands as it is executed. Useful for debugging
set -x

# Check dependencies
aws --version
terraform --version

terraform init -reconfigure -input=false
terraform plan -input=false -var-file=terraform.tfvars
terraform apply -auto-approve -input=false -var-file=terraform.tfvars