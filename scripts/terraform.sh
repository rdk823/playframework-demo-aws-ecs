#!/usr/bin/env bash

# Make the script to abort if any command fails
set -e

# Print the commands as it is executed. Useful for debugging
set -x

# Check dependencies
aws --version
terraform --version

# Set environment vatiables
export AWS_ACCESS_KEY_ID=${{ secrets.AwsAccessKeyId }
export AWS_SECRET_ACCESS_KEY=${{ secrets.AwsSecretAccessKey }}
export AWS_DEFAULT_REGION="us-east-1"
export AWS_DEFAULT_OUTPUT="json"

terraform init -reconfigure -input=false
terraform plan -input=false -var-file=terraform.tfvars

terraform apply -auto-approve -input=false -var-file=terraform.tfvars