from pyspark.sql import SparkSession

# Cria sessão Spark
spark = SparkSession.builder.appName("Gerar dim_payment_type").getOrCreate()

# Cria o DataFrame com os dados fixos
dim_payment_type_df = spark.createDataFrame([
    (1, "Credit card"),
    (2, "Cash"),
    (3, "No charge"),
    (4, "Dispute"),
    (5, "Unknown"),
    (6, "Voided trip")
], ["payment_type", "payment_desc"])

# Caminho de saída no S3
output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/delivery/dim_payment_type/"

# Escreve como Parquet
dim_payment_type_df.write.mode("overwrite").parquet(output_path)

print(f"dim_payment_type gerada em {output_path}")