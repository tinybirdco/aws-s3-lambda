import re
import os
import uuid
import json
import logging
import urllib3
import boto3
from urllib.parse import urlencode
from botocore.exceptions import ClientError


# AWS S3
s3_client = boto3.client('s3')

# Tinybird datasource url
url = f'https://api.tinybird.co/v0/datasources?'

def process_name(key):
    key = key.replace('.csv', '')
    file_regexp = os.getenv('FILE_REGEXP', None)
    if not file_regexp:
        return key
    m = re.search(file_regexp, key)
    return m.group(0) if m is not None else key

def create_presigned_url(bucket_name, object_name, expiration=3600):
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL
    return response

def upload_to_tinybird(csv_path, name):
    http = urllib3.PoolManager()
    fields = {
        'mode': 'append',
        'name': name.replace('.csv',''),
        'url': csv_path
    }
    headers={
        'Authorization': 'Bearer ' + os.environ['TB_TOKEN']
    }
    return http.request('POST', url + urlencode(fields), headers=headers)
    

def lambda_handler(event, context):
    status = 200
    responses = []

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        csv_path = create_presigned_url(bucket, key)
        name = process_name(key)
        r = upload_to_tinybird(csv_path, name=name)
        status = r.status if r.status != 200 else status
        responses.append({
            'status': r.status,
            'name': name,
            'bucket': bucket,
            'tb_data': json.loads(r.data.decode('utf-8'))
        })

    return {
        'status': status,
        'responses': responses
    }