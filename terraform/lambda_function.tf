
# Role 1
resource "aws_iam_role" "AWSLambdaBasicExecutionRole" {
  name               = "AWSLambdaBasicExecutionRole"
  assume_role_policy = jsonencode({
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
                "arn:aws:logs:us-east-1:306094678557:log-group:/aws/lambda/lambda-save-files-in-s3:*"
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
			"Action": [
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::eedb-015-2025-1-grupo-c-projeto-integrador/raw/taxi/*",
				"arn:aws:s3:::eedb-015-2025-1-grupo-c-projeto-integrador/raw/holiday/*",
				"arn:aws:s3:::eedb-015-2025-1-projeto-integrador-grupo-c/raw/taxi/*",
				"arn:aws:s3:::eedb-015-2025-1-projeto-integrador-grupo-c/raw/holiday/*"
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
			"Action": [
				"lambda:InvokeFunction",
				"logs:*"
			],
			"Resource": "*"
		}
	]
  })
}
