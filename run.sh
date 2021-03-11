#!/bin/bash

TB_ROLE_NAME=tb-lambda-role
TB_POLICY_NAME=tb-lambda-policy
TB_FUNCTION_NAME=tb-lambda-import-function
TB_PERMISSION_ID=1
S3_URI=s3://automatic-ingestion-poc/datasources/

# Get account id number
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | grep -Eo '[0-9]+')

# Create lambda role
printf '=%.0s' {1..10} && echo -n '  Create lambda role  ' && printf '=%.0s' {1..10} && echo
aws iam create-role \
  --role-name $TB_ROLE_NAME \
  --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole" }]}' \
  2>&1
echo -e

# Create specific Policy
printf '=%.0s' {1..10} && echo -n '  Create specific Policy  ' && printf '=%.0s' {1..10} && echo
aws iam create-policy \
  --policy-name $TB_POLICY_NAME \
  --policy-document file://policy.json \
  2>&1
echo -e

# Add permissions for Lambda Basic Execution -> This gives permission to upload logs to CloudWatch
printf '=%.0s' {1..10} && echo -n '  Add policy permissions to Role  ' && printf '=%.0s' {1..10} && echo
aws iam attach-role-policy \
  --role-name $TB_ROLE_NAME \
  --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/$TB_POLICY_NAME \
  2>&1
echo -e

# Zip lambda funcion
printf '=%.0s' {1..10} && echo -n '  Zip lambda funcion  ' && printf '=%.0s' {1..10} && echo
zip tb-deployment-package.zip lambda_function.py
echo -e

# Waiting 10 secs for policies to update
printf '=%.0s' {1..10} && echo -n '  Waiting 10 secs for policies to update  ' && printf '=%.0s' {1..10} && echo
for i in {1..10}; do echo -n $i' ' && sleep 1; done
echo -e

# Create function
printf '=%.0s' {1..10} && echo -n '  Create Lambda function  ' && printf '=%.0s' {1..10} && echo
aws lambda create-function \ 
  --function-name $TB_FUNCTION_NAME \ 
  --zip-file fileb://tb-deployment-package.zip \
  --handler lambda_function.lambda_handler \
  --runtime python3.8 \
  --role arn:aws:iam::$AWS_ACCOUNT_ID:role/$TB_ROLE_NAME \
  2>&1
echo -e

# Add S3 execution rights to lambda function
printf '=%.0s' {1..10} && echo -n '  Add S3 execution rights to lambda function  ' && printf '=%.0s' {1..10} && echo
aws lambda add-permission \
--function-name $TB_FUNCTION_NAME \
--action lambda:InvokeFunction \
--principal s3.amazonaws.com \
--source-arn $S3_URI \
--statement-id $TB_PERMISSION_ID \
  2>&1
echo -e

# Add S3 Trigger (Notification)
printf '=%.0s' {1..10} && echo -n '  Add S3 Trigger (Notification)  ' && printf '=%.0s' {1..10} && echo
aws s3api put-bucket-notification-configuration \
--bucket $S3_URI \
--notification-configuration file://s3trigger.json \
  2>&1

