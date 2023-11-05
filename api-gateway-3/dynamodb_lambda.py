import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('student')

    # Use the scan operation to fetch all records
    response = table.scan()

    items = response.get('Items', [])
    return {
        'statusCode': 200,
        'body': json.dumps(items)
    }
