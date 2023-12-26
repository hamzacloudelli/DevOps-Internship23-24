import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('hamzaciDynamoDB')  # Replace with your DynamoDB table name

def lambda_handler(event, context):
    table.put_item(
        Item={"UserId": "user1", "Name": "John Doe",
              "UserId": "user2", "Name": "123 Main St"}
        # Add more items as needed
    )

    return {
        'statusCode': 200,
        'body': 'Items added successfully!'
    }
