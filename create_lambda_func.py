import boto3

# AWS Lambda
lambda_client = boto3.client('lambda')


def run():
    response = lambda_client.create_function(
        Code={
            'S3Bucket': 'my-bucket-1xpuxmplzrlbh',
            'S3Key': 'function.zip',
        },
        Description='Process image objects from Amazon S3.',
        Environment={
            'Variables': {
                'TB_TOKEN': 'p.eyJ1IjogImI5OGZmMTYxLTFkOWItNDJlZS05M2I4LWQ2YjlhYzhkODJkYyIsICJpZCI6ICI4ZWY3NWY0NS05YWM1LTQyN2ItYWYxOS1mNjU4NzAzNzUwMmIifQ.rXAQfNJo6IJ_MBDkrgZITfJPNyT4PAr7OkUgqxsHq9M',
            },
        },
        FunctionName='tinybird-import-lambda',
        Handler='index.handler',
        KMSKeyArn='arn:aws:kms:us-west-2:123456789012:key/b0844d6c-xmpl-4463-97a4-d49f50839966',
        MemorySize=256,
        Publish=True,
        Role='arn:aws:iam::123456789012:role/lambda-role',
        Runtime='python3.8',
        Tags={
            'DEPARTMENT': 'Assets',
        },
        Timeout=15,
        TracingConfig={
            'Mode': 'Active',
        },
    )

    print(response)


if __name__ == '__main__':
    run()