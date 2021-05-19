#!/bin/bash

# For this script to work you need to install and configure the aws cli

# Modify the environment variables according to your needs
source .env-cloudwatch

# Get AWS account id and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | grep -Eo '[0-9]+')
REGION_ID=$(aws configure get region)

# Remove zip
printf '=%.0s' {1..10} && echo -n '  Remove zip  ' && printf '=%.0s' {1..10} && echo
rm tb-deployment-package.zip
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
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
  2>&1
echo -e

# Delete Role
printf '=%.0s' {1..10} && echo -n '  Delete role  ' && printf '=%.0s' {1..10} && echo
aws iam delete-role \
  --role-name $TB_ROLE_NAME \
  2>&1
echo -e
