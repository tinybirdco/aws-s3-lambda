#!/bin/bash

# For this script to work you need to install and configure the aws cli

# Modify the environment variables according to your needs
source .env-cloudwatch

# Get AWS account id and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | grep Account | awk '{print $2}' | grep -Eo '[0-9]+')
REGION_ID=$(aws configure get region)

# Create lambda role
printf '=%.0s' {1..10} && echo -n '  Create lambda role  ' && printf '=%.0s' {1..10} && echo
aws iam create-role \
  --role-name $TB_ROLE_NAME \
  --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole" }]}' \
  2>&1
echo -e

# Attach execution Policy
printf '=%.0s' {1..10} && echo -n '  Attach Policy  ' && printf '=%.0s' {1..10} && echo
aws iam attach-role-policy --role-name $TB_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>&1
echo -e

# Zip lambda funcion
printf '=%.0s' {1..10} && echo -n '  Zip lambda funcion  ' && printf '=%.0s' {1..10} && echo
mkdir deploy
cp cloudwatch_logs.py deploy
cd deploy
pip install requests --target .
zip -r ../tb-deployment-package.zip *
cd ..
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
    --role arn:aws:iam::$AWS_ACCOUNT_ID\:role/$TB_ROLE_NAME \
    --handler cloudwatch_logs.handler \
    --environment '{ "Variables": { "TB_TOKEN": "'"$TB_TOKEN"'", "FILE_REGEXP": "'"$FILE_REGEXP"'" } }' \
    --runtime python3.8 \
    2>&1
echo -e

# Add CloudWatch logs execution rights to lambda function
printf '=%.0s' {1..10} && echo -n '  Add CloudWatch logs rights to lambda function  ' && printf '=%.0s' {1..10} && echo
SOURCE_ARN=arn:aws:logs:$REGION_ID\:$AWS_ACCOUNT_ID\:log-group:TestLambda:*
aws lambda add-permission \
    --function-name $TB_FUNCTION_NAME \
    --statement-id $TB_FUNCTION_NAME \
    --principal "logs.$REGION_ID.amazonaws.com" \
    --action "lambda:InvokeFunction" \
    --source-arn $SOURCE_ARN \
    --source-account "$AWS_ACCOUNT_ID" \
    2>&1
echo -e

# Create log group
# done manually by now

# Create log stream
# done manually by now


# Add CloudWatch logs subscription
printf '=%.0s' {1..10} && echo -n '  Add CloudWatch logs subscription  ' && printf '=%.0s' {1..10} && echo
aws logs put-subscription-filter \
    --log-group-name TestLambda \
    --filter-name demo \
    --filter-pattern " " \
    --destination-arn arn:aws:lambda:$REGION_ID\:$AWS_ACCOUNT_ID\:function:$TB_FUNCTION_NAME


aws logs put-log-events --log-group-name TestLambda --log-stream-name stream1 --log-events "[{\"timestamp\":`node -e 'console.log(Date.now())'` , \"message\": \"Simple Lambda Test\"}]" \
--sequence-token 49616913400610192577031255983856398713420083766493184418
aws logs put-log-events --log-group-name TestLambda --log-stream-name stream1 --log-events "[{\"timestamp\":<CURRENT TIMESTAMP MILLIS> , \"message\": \"Simple Lambda Test\"}]"



aws lambda update-function-code \
    --function-name $TB_FUNCTION_NAME \
    --zip-file fileb://tb-deployment-package.zip \
    --environment '{ "Variables": { "TB_TOKEN": "'"$TB_TOKEN"'", "FILE_REGEXP": "'"$FILE_REGEXP"'" } }' \
    --runtime python3.8 \
    2>&1