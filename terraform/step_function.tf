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
        Next = "delivery_dim_location"
      }

      "delivery_dim_location" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "delivery_dim_location"
        }
        Next = "delivery_dim_ratecode"
      }

      "delivery_dim_ratecode" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "delivery_dim_ratecode"
        }
        Next = "delivery_dim_payment_type"
      }

      "delivery_dim_payment_type" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "delivery_dim_payment_type"
        }
        Next = "delivery_dim_vendor"
      }

      "delivery_dim_vendor" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "delivery_dim_vendor"
        }
        Next = "delivery_fact_taxi_trip"
      }

      "delivery_fact_taxi_trip" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "delivery_fact_taxi_trip"
        }
        Next = "dummy_job"
      }

      "dummy_job" = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = "dummy_job"
        }
        End = true
      }

    }
  })
}
