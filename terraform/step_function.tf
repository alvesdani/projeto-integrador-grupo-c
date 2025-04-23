#Test
resource "aws_sfn_state_machine" "pipeline" {
  name     = "pipeline"
  role_arn = "arn:aws:iam::306094678557:role/service-role/StepFunctions--role-9pee1bvoa"

  definition = jsonencode({
    Comment = "Step Function para orquestrar Lambda e Glue Jobs"
    StartAt = "Lambda Invoke"
    States = {
      "Lambda Invoke" = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "arn:aws:lambda:us-east-1:306094678557:function:lambda-save-files-in-s3:$LATEST"
          Payload = {
            "input.$" = "$"
          }
        }
        ResultPath = "$.lambdaResult"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
            IntervalSeconds = 1
            MaxAttempts     = 3
            BackoffRate     = 2
          }
        ]
        Next = "holiday_trusted"
      }

      "holiday_trusted" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "trusted_holiday_ny"
        }
        Next = "taxi_trusted"
      }

      "taxi_trusted" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "trusted_taxi_travel_records"
        }
        End = true
      }
    }
  })
}
