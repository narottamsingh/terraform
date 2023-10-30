import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('student')

    response = table.get_item(
        Key={
            'student_id': '101'
        }
    )

    item = response.get('Item')
    return {
        'statusCode': 200,
        'body': json.dumps(item)
    }
