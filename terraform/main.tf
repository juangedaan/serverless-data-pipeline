
provider "aws" {
  region = "us-west-2"
}

resource "aws_kinesis_stream" "stream" {
  name             = "demo-stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_dynamodb_table" "table" {
  name           = "demo-items"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "processor" {
  filename         = "../lambda/function.zip"
  function_name    = "stream-processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../lambda/function.zip")
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.table.name
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_kinesis" {
  event_source_arn = aws_kinesis_stream.stream.arn
  function_name    = aws_lambda_function.processor.arn
  starting_position = "LATEST"
}
