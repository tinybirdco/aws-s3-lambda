#!/bin/bash

# For this script to work you need to install and configure the aws cli

# Modify the environment variables according to your needs
source .env

# Get AWS account id and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | grep -Eo '[0-9]+')
REGION_ID=$(aws configure get region)

# Remove zip
printf '=%.0s' {1..10} && echo -n '  Remove zip  ' && printf '=%.0s' {1..10} && echo
rm tb-deployment-package.zip
echo -e

# Remove lambda S3 permission
printf '=%.0s' {1..10} && echo -n '  Remove lambda S3 permission  ' && printf '=%.0s' {1..10} && echo
aws lambda remove-permission \
  --function-name $TB_FUNCTION_NAME \
  --statement-id $TB_PERMISSION_ID \
  2>&1
echo -e

# Delete lambda function
printf '=%.0s' {1..10} && echo -n '  Delete lambda function  ' && printf '=%.0s' {1..10} && echo
aws lambda delete-function \
  --function-name $TB_FUNCTION_NAME \
  2>&1
echo -e

# Detach policies from role
printf '=%.0s' {1..10} && echo -n '  Detach policies from role  ' && printf '=%.0s' {1..10} && echo
aws iam detach-role-policy \
  --role-name $TB_ROLE_NAME \
  --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$TB_POLICY_NAME \
  2>&1
echo -e

# Remove policy
printf '=%.0s' {1..10} && echo -n '  Remove policy  ' && printf '=%.0s' {1..10} && echo
aws iam delete-policy \
  --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$TB_POLICY_NAME \
  2>&1
echo -e

# Delete Role
printf '=%.0s' {1..10} && echo -n '  Delete role  ' && printf '=%.0s' {1..10} && echo
aws iam delete-role \
  --role-name $TB_ROLE_NAME \
  2>&1
echo -e
