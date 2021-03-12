#!/bin/bash

TB_ROLE_NAME=tb-lambda-role
TB_POLICY_NAME=tb-lambda-policy
TB_FUNCTION_NAME=tb-lambda-import-function
AWS_ACCOUNT_ID=473819596691
TB_PERMISSION_ID=1

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
