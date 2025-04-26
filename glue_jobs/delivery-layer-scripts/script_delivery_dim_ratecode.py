from pyspark.sql import SparkSession

# Inicia a sessão Spark
spark = SparkSession.builder.appName("Gerar dim_ratecode").getOrCreate()

# Cria o DataFrame com os valores fixos
dim_ratecode_df = spark.createDataFrame([
    (1, "Standard rate"),
    (2, "JFK"),
    (3, "Newark"),
    (4, "Nassau or Westchester"),
    (5, "Negotiated fare"),
    (6, "Group ride")
], ["ratecode_id", "ratecode_desc"])

# Caminho S3 para salvar
output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/delivery/dim_ratecode/"

# Escreve como Parquet
dim_ratecode_df.write.mode("overwrite").parquet(output_path)

print(f"dim_ratecode gerada em {output_path}")