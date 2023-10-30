# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "dynamodb_lambda.py"
  output_path = "dynamodb_lambda.zip"
}

# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaDynamoDBRole"
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

# Attach an inline policy to the role to allow access to DynamoDB
resource "aws_iam_policy" "dynamodb_read_policy" {
  name = "DynamoDBReadPolicy"

  description = "Policy for reading from DynamoDB"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:ap-south-1:291548415763:table/student"
        }
    ]
}
)
}

# Attach the policy to the role
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "LambdaDynamoDBPolicyAttachment"
  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
  roles      = [aws_iam_role.lambda_execution_role.name]
}


resource "aws_lambda_function" "dynamodb_reader_lambda" {
  function_name = "DynamoDBReaderLambda"
  description   = "Lambda function to read data from DynamoDB"
  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  role = aws_iam_role.lambda_execution_role.arn
  handler = "dynamodb_lambda.lambda_handler"
  runtime = "python3.9"
  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}