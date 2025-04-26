from pyspark.sql import SparkSession

# Inicia a sessão Spark
spark = SparkSession.builder.appName("Gerar dim_location").getOrCreate()

# Caminho do arquivo CSV no S3
csv_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/raw/taxi_zone_lookup/taxi_zone_lookup.csv"

# Lê o CSV com header
dim_location_df = spark.read.option("header", True).csv(csv_path)

# Renomeia e padroniza os nomes das colunas
dim_location_df = dim_location_df.selectExpr(
    "CAST(LocationID AS INT) AS location_id",
    "Borough AS borough",
    "Zone AS zone",
    "service_zone"
)

# Caminho para salvar como Parquet
output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/delivery/dim_location/"

# Escreve em Parquet
dim_location_df.write.mode("overwrite").parquet(output_path)

print(f"dim_location gerada com sucesso em: {output_path}")
