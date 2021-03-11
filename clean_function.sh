#!/bin/bash

TB_ROLE_NAME=tb-lambda-role
TB_POLICY_NAME=tb-lambda-policy
TB_FUNCTION_NAME=tb-lambda-import-function
AWS_ACCOUNT_ID=473819596691
TB_PERMISSION_ID=1

rm tb-deployment-package.zip

aws lambda remove-permission --function-name $TB_FUNCTION_NAME --statement-id $TB_PERMISSION_ID
aws lambda delete-function --function-name $TB_FUNCTION_NAME
aws iam detach-role-policy --role-name $TB_ROLE_NAME --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$TB_POLICY_NAME
aws iam delete-policy --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$TB_POLICY_NAME
aws iam delete-role --role-name $TB_ROLE_NAME
