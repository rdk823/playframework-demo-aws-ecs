# Playframework Webservice AWS ECS

This repository contains the code to deploy an AWS ECS cluster in a VPC using Terraform.

Below are steps to deploy the infrastructure.

## Prerequisites

### AWS account setup

Setup AWS account with a `IAM user` that has permissions to create following resources:

- ECS Fargate
- VPC
- Route53 zone records
- Create S3 bucket
- Create DynamoDB table

### AWS Route53 Zone

You'll need to provide domain name for the AWS ACM certificate and AWS ALB creation. Please make sure you have Route53 zone created.


### GitHub Actions setup

This project uses GitLab Actions pipeline for the deployment. Please fork this repository before proceeding.

Add the following details of your AWS account to your repository GitHub secrets

| Secret Key | Secret Value |
|---|---|
| AwsAccessKeyId | Access Key of AWS IAM user |
| AwsSecretAccessKey | Secret of the Key of AWS IAM user |


## Deploying the infrastructure

### Provide Terraform input variables

Edit the `variables.tf` file with your values. Please make sure you provide your domain name to the variable `acm_cert_domain`.

### Commit changes
Once done with the changes and when you're ready to deploy, prefix your commit message with `DEPLOY` to trigger the deployment.

```console
git commit -m "DEPLOY - ..."
```

This will trigger the terraform `terraform-deploy` job.

The job will create following resources:

- S3 bucket, a DynamoDB table and a KMS key for Terraform remote state.
- VPC with public and private subnets
- NAT gateway
- ECR repository
- ECS cluster with Fargate
- ALB and target groups
- ACM certificate with auto validation for the ALB
- A Route53 record `www.yourdomain.tld`


## Destroying the infrastructure

To destroy the infrastructure, edit any file and prefix your commit message with `DESTROY` to trigger the `terraform-destroy` job.

```console
git commit -m "DESTROY- ..."
```
This will destroy your AWS ECS infrastructure.