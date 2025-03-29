
import json
import boto3
import base64
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    for record in event['Records']:
        payload = base64.b64decode(record['kinesis']['data'])
        item = json.loads(payload)
        table.put_item(Item=item)
    return {"statusCode": 200, "body": "Processed"}
