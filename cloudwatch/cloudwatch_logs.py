import json
import gzip
import base64

import requests
import csv
import os

from io import StringIO
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

host = 'https://api.tinybird.co'

def handler(event, context):
    cloudwatch_event = event["awslogs"]["data"]
    decode_base64 = base64.b64decode(cloudwatch_event)
    decompress_data = gzip.decompress(decode_base64)
    log_data = json.loads(decompress_data)
    print(log_data)

    mode = 'append'
    datasource = 'cloudwatch_test' #self.data_source
    token = os.environ['TB_TOKEN']

    url = f'{host}/v0/datasources?mode={mode}&name={datasource}'

    retry = Retry(total=5, backoff_factor=10)
    adapter = HTTPAdapter(max_retries=retry)
    _session = requests.Session()
    _session.mount('http://', adapter)
    _session.mount('https://', adapter)

    csv_chunk = StringIO()
    writer = csv.writer(csv_chunk, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)

    writer.writerow([json.dumps(log_data)])

    data = csv_chunk.getvalue()
    headers = {
        'Authorization': f'Bearer {token}',
        'X-TB-Client': 'cloudwatch-0.1',
    }

    response = _session.post(url, headers=headers, files=dict(csv=data))
    return {
        'status': response.status_code,
        'tb_data': json.dumps(response.json())
    }