# Provider específico para Lambda
provider "aws" {
  alias  = "lambda"
  region = "us-east-1"
}

resource "aws_s3_bucket" "lambda_s3" {
  bucket = "eedb-015-2025-1-projeto-integrador-grupo-c-nv"
  acl    = "private"
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_s3.bucket
  key    = "lambda_function.py"
  source = "lambda/scripts/lambda_function.py"  # Caminho local do arquivo .py
  acl    = "private"
}

# Role 1
resource "aws_iam_role" "AWSLambdaBasicExecutionRole" {
  name               = "AWSLambdaBasicExecutionRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy" "lambda-logs-policy" {
  name = "lambda-logs-policy"
  role = aws_iam_role.AWSLambdaBasicExecutionRole.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:us-east-1:306094678557:*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:us-east-1:306094678557:log-group:/aws/lambda/lambda_function:*"
          ]
      }
    ]
  })
}

# Role 2
resource "aws_iam_role" "lambda-write-raw-data-s3" {
  name               = "lambda-write-raw-data-s3"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",  # Corrigido para sts:AssumeRole
            "Principal": {
                "Service": "lambda.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy" "lambda-s3-write-policy" {
  name = "lambda-s3-write-policy"
  role = aws_iam_role.lambda-write-raw-data-s3.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "s3:PutObject",
          "Resource": [
              "arn:aws:s3:::eedb-015-2025-1-grupo-c-projeto-integrador/raw/taxi/*",
              "arn:aws:s3:::eedb-015-2025-1-grupo-c-projeto-integrador/raw/holiday/*",
              "arn:aws:s3:::eedb-015-2025-1-projeto-integrador-grupo-c-nv/raw/taxi/*",
              "arn:aws:s3:::eedb-015-2025-1-projeto-integrador-grupo-c-nv/raw/holiday/*"
          ]
      }
    ]
  })
}

# Role 3
resource "aws_iam_role" "monitoring_sf" {
  name               = "monitoring_sf"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",  # Corrigido para sts:AssumeRole
            "Principal": {
                "Service": "lambda.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy" "monitoring-policy" {
  name = "monitoring-policy"
  role = aws_iam_role.monitoring_sf.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "lambda:InvokeFunction",
              "logs:*"
          ],
          "Resource": "*"
      }
    ]
  })
}

