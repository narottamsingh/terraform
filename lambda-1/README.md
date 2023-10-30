run terraform init to initialize.

run terraform apply to see it work.

run terraform destroy to clean up.

Test : Function: 
aws lambda invoke --function-name=hello_lambda out.txt

aws lambda invoke --function-name=DynamoDBReaderLambda out.txt