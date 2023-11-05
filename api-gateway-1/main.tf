provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Create an IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create the Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-lambda-function"
  handler = "lambda_function.handler"
  runtime = "python3.8"
  role = aws_iam_role.lambda_role.arn

  # Zip your Lambda function code (lambda_function.py) and provide the filename
  filename = "lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
}

# Create an API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "My API description testing"
}

# Create a Resource
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "my-api"
}

# Create an HTTP Method
resource "aws_api_gateway_method" "my_get_method" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "GET"
  authorization = "NONE"
}

# Define the Integration Request

resource "aws_api_gateway_integration" "my_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.my_get_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"  # Use POST for Lambda integrations
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:291548415763:function:my-lambda-function/invocations"
  #uri                     = "arn:aws:lambda:ap-south-1:291548415763:function:my-lambda-function/invocations"
  #uri                     = aws_lambda_function.my_lambda.invoke_arn
}

# Create a Method Response
resource "aws_api_gateway_method_response" "my_get_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.my_get_method.http_method
  status_code = "200"
}

# Create an Integration Response
resource "aws_api_gateway_integration_response" "my_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.my_get_method.http_method
  status_code = aws_api_gateway_method_response.my_get_response.status_code
}

# Deploy the API to a Stage
resource "aws_api_gateway_deployment" "my_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name = "test"

  # Define the stage settings (e.g., caching, logging, etc.)
  description = "Production Stage"
  depends_on =[aws_api_gateway_method.my_get_method,aws_api_gateway_integration.my_get_integration]
 
}

# Create a Stage
resource "aws_api_gateway_stage" "my_api_stage" {
  deployment_id = aws_api_gateway_deployment.my_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name   = "test"
}

# Create a Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "apigateway.amazonaws.com"
}
