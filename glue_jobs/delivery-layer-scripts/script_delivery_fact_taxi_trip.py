from pyspark.sql import SparkSession
from pyspark.sql.functions import sha2, concat_ws, col, to_date, lit, when, date_format

# Inicia Spark
spark = SparkSession.builder.appName("Gerar fact_taxi_trip com feriado e dia da semana").getOrCreate()

# Caminhos
trusted_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/trusted/taxi_travel_records/"
holiday_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/delivery/dim_holiday_ny/"
output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/delivery/fact_taxi_trip/"

# Lê dados trusted
df = spark.read.option("basePath", trusted_path).parquet(trusted_path)

# Gera trip_id
df = df.withColumn("trip_id", sha2(concat_ws("::", 
    col("vendor_id"), 
    col("tpep_pickup_datetime"), 
    col("tpep_dropoff_datetime"), 
    col("pulocation_id"), 
    col("dolocation_id")), 256))

# Renomeia campos
df = df.withColumnRenamed("tpep_pickup_datetime", "pickup_datetime") \
       .withColumnRenamed("tpep_dropoff_datetime", "dropoff_datetime")

# Extrai data e dia da semana
df = df.withColumn("data_corrida", to_date("pickup_datetime")) \
       .withColumn("day_of_week", date_format("pickup_datetime", "EEEE"))  # Ex: Monday, Tuesday...

# Lê feriados
df_holiday = spark.read.parquet(holiday_path)

# Join com feriados
df = df.join(
    df_holiday.select("date", "holiday_name"),
    df["data_corrida"] == df_holiday["date"],
    "left"
).drop("date", "data_corrida")

# Campo is_holiday
df = df.withColumn("is_holiday", when(col("holiday_name").isNotNull(), lit(True)).otherwise(lit(False)))

# Seleciona colunas finais
fact_df = df.select(
    "trip_id", "vendor_id", "pickup_datetime", "dropoff_datetime",
    "passenger_count", "trip_distance", "ratecode_id", "store_and_fwd_flag",
    "pulocation_id", "dolocation_id", "payment_type", 
    "fare_amount", "tip_amount", "tolls_amount", "total_amount",
    "is_holiday", "holiday_name", "day_of_week",
    "year", "month", "day"
)

# Escreve no S3
fact_df.write.partitionBy("year", "month", "day").mode("overwrite").parquet(output_path)

print("fact_taxi_trip gerada com is_holiday, holiday_name e day_of_week!")
