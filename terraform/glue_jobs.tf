resource "aws_glue_job" "trusted_taxi_travel_records" {
  name     = "trusted_taxi_travel_records"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/trusted-layer-scripts/script_trusted.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "trusted_holiday_ny" {
  name     = "trusted_holiday_ny"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/trusted-layer-scripts/script_holiday_trusted.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "delivery_fact_taxi_trip" {
  name     = "delivery_fact_taxi_trip"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD" 

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/script_delivery_fact_taxi_trip.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true" #revisar!!
  }

  max_retries = 0
  timeout     = 480 
}

resource "aws_glue_job" "delivery_dim_vendor" {
  name     = "delivery_dim_vendor"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/script_delivery_dim_vendor.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "delivery_dim_payment_type" {
  name     = "delivery_dim_payment_type"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/script_delivery_dim_payment_type.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "delivery_dim_ratecode" {
  name     = "delivery_dim_ratecode"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/script_delivery_dim_ratecode.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "delivery_dim_location" {
  name     = "delivery_dim_location"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/script_delivery_dim_location.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true"
  }

  max_retries = 0
  timeout     = 60
}

resource "aws_glue_job" "dummy_job" {
  name     = "dummy_job"
  role_arn = "arn:aws:iam::306094678557:role/role_exercicio"

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    name            = "glueetl"
    script_location = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/scripts/delivery-layer-scripts/dummy.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                   = "python"
    "--TempDir"                        = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/glue/temp/"
    "--enable-metrics"                 = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"        = "true"
  }

  max_retries = 0
  timeout     = 60
}
