resource "aws_iam_role" "step_function_role" {
  name = "step_function_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_function_policy" {
  name = "step_function_policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "arn:aws:lambda:us-east-1:306094678557:function:lambda-save-files-in-s3"
      },
      {
        Effect = "Allow",
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "etl_pipeline_step_function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Executa lambda + glue em sequência",
    StartAt = "LambdaInvoke",
    States = {
      LambdaInvoke = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = "arn:aws:lambda:us-east-1:306094678557:function:lambda-save-files-in-s3",
          Payload      = {}
        },
        ResultPath = "$.lambda",
        Next       = "GlueJobHoliday"
      },
      GlueJobHoliday = {
        Type     = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = "trusted_holiday_ny"
        },
        ResultPath = "$.glue_holiday",
        Next       = "GlueJobTaxi"
      },
      GlueJobTaxi = {
        Type     = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = "trusted_taxi_travel_records"
        },
        ResultPath = "$.glue_taxi",
        End        = true
      }
    }
  })
}