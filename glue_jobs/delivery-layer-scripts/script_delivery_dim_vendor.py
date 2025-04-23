from pyspark.sql import SparkSession
from pyspark.sql.functions import lit

# Criar sessão Spark
spark = SparkSession.builder.appName("Gerar dim_vendor").getOrCreate()

# Criar DataFrame manualmente com os valores fixos
dim_vendor_df = spark.createDataFrame([
    (1, "Creative Mobile Technologies, LLC"),
    (2, "VeriFone Inc.")
], ["vendor_id", "vendor_name"])

# Caminho de saída no S3
output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c/delivery/dim_vendor/"

# Escrever como Parquet
dim_vendor_df.write.mode("overwrite").parquet(output_path)

print(f"dim_vendor gerada em {output_path}")