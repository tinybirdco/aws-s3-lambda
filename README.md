# AWS S3 + Lambda -> Automatically ingesting to Tinybird from S3

This repository contains a shell script that configures an AWS Lambda function that is automatically triggered each time a new CSV file is uploaded to a given AWS S3 bucket.

The AWS Lambda function appends the contents of the CSV file to a Tinybird Data Source.

## How to start

- Install the `aws` CLI
- Run `aws configure` and set your AWS client keys and region.
- Run `cp .env_sample .env` and edit the `.env` file to customize the `run.sh` script. These are the available variables:

```sh
# name of the aws role (it will be created by the run.sh script)
TB_ROLE_NAME=
# name of the aws policy (it will be created by the run.sh script)
TB_POLICY_NAME=
# name of the aws lambda function (it will be created by the run.sh script)
TB_FUNCTION_NAME=
TB_PERMISSION_ID=1
# if you upload a file called products__2021-01-01.csv it'll ingest the contents in the Tinybird products Data Source
FILE_REGEXP='^[^_]+(?=_)'
# Tinybird token with DATASOURCE:CREATE permission (or admin token). Get it from https://ui.tinybird.co/tokens
TB_TOKEN=
# Tinybird API host. It depends on the region or if you have a dedicated host (eu=https://api.tinybird.co) (us-east=https://api.us-east.tinybird.co) default is `eu` host
TB_HOST=
# The name of the S3 bucket to listen to. Files need to be in the root of the bucket
S3_BUCKET=
```

Most of the variables are provided with default values, so you just have to indicate `TB_TOKEN` to ingest to your Tinybird account and `S3_BUCKET`. TB_HOST is `https://api.tinybird.co` by default, just set it if your account is in a different region than `eu`

## How to use it

Run: 

```bash
./run.sh
```

Once finished, go to the AWS console and check the lambda function is there and the `TB_TOKEN` and `FILE_REGEXP` variables required to run the script are available.

Once deployed, you can just drop CSV files in the `S3_BUCKET` and they'll be automatically ingested to the corresponding Tinybird Data Source defined by the FILE_REGEXP environment variable, by default it uses as the Data Source name the part of the CSV file name before the first underscore character, otherwise it takes the CSV file name.

![](output.gif)

## How to delete the Lambda function

If you want to clean the function, roles, policies and triggers:

```bash
./clean_function.sh
```
