#!/usr/bin/env bash
#
# Init variables
AWS_REGION=us-east-1
BUCKET_NAME=terraform-playframework-demo
KMS_KEY_ALIAS=alias/playframework-demo-key
DB_TABLE=terraform-playframework-demo


if aws s3 ls | grep $BUCKET_NAME > /dev/null 2>&1; then
    echo "Remote state bucket $BUCKET_NAME already exists. Skipping..." > /dev/null 2>&1
else
    aws s3api create-bucket --bucket $BUCKET_NAME
fi

  # Create remote kms key
if aws kms list-aliases --output text | grep $KMS_KEY_ALIAS > /dev/null 2>&1; then
    echo "KMS key $KMS_KEY_ALIAS already exists. Skipping..." > /dev/null 2>&1
    KMS_KEY_ID=$(aws kms describe-key --key-id $KMS_KEY_ALIAS | jq --raw-output '.KeyMetadata.KeyId')
else
    KMS_KEY_ID=$(aws kms create-key \
        --description "KMS key used to encrypt and decrypt remote state file" \
        --key-usage ENCRYPT_DECRYPT \
        \
        | jq --raw-output '.KeyMetadata.KeyId')
    # Create key alias
    aws kms create-alias --alias-name $KMS_KEY_ALIAS --target-key-id $KMS_KEY_ID
fi

# Create remote state dynamodb table
if aws dynamodb list-tables --output text | grep $DB_TABLE > /dev/null 2>&1; then
    echo "Remote state dynamodb table $DB_TABLE already exists. Skipping..." > /dev/null 2>&1
else
    aws dynamodb create-table \
        --table-name $DB_TABLE \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10
    
fi


cat <<BACKEND
region         = "${AWS_REGION}"
encrypt        = true
bucket         = "${BUCKET_NAME}"
key            = "terraform.tfstate"
kms_key_id     = "${KMS_KEY_ID}"
dynamodb_table = "${DB_TABLE}"

BACKEND
