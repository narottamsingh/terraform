provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region
}

# Create an API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "My API description"
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
  uri                     = "arn:aws:apigateway:ap-south-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-south-1:291548415763:function:DynamoDBReaderLambda/invocations"
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
}

# Create a Stage
resource "aws_api_gateway_stage" "my_api_stage" {
  deployment_id = aws_api_gateway_deployment.my_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name   = "test"
  # Check if the stage already exists
  #count = aws_api_gateway_stage.my_api_stage_names["test"] == 0 ? 1 : 0
}



# Data source to get existing stage names
#data "aws_api_gateway_stage" "existing_stages" {
#  rest_api_id = aws_api_gateway_rest_api.my_api.id
#}

# Create a map of existing stage names
#data "map" "my_api_stage_names" {
#  for_each = data.aws_api_gateway_stage.existing_stages.names
#  content {
#    name = each.key
#  }
#}

# Create a Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:ap-south-1:291548415763:function:DynamoDBReaderLambda" // change arm lambda
  principal     = "apigateway.amazonaws.com"
}
