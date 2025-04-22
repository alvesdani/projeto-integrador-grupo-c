resource "aws_glue_job" "delivery_fact_taxi_trip" {
  name     = "delivery_fact_taxi_trip"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD" 

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/glue/scripts/delivery-layer-scripts/script_delivery_fact_taxi_trip.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true" #revisar!
  }

  max_retries = 0
  timeout     = 480 
}
