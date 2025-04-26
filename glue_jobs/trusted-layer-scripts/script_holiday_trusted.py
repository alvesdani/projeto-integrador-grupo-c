

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.functions import to_date
import re
import sys


# Criar a Spark Session
spark = SparkSession.builder \
    .appName("Process data holidays") \
    .getOrCreate()
    
# Ler o arquivo Json
df = spark.read.json("s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/raw/holiday/public_holidays_2024.json")


### Padronizar nomenclatura

# Função para transformar o nome da coluna
def transformar_nome_coluna(nome_coluna):
    # Substitui letras maiúsculas no meio do nome da coluna por um underscore e a letra minúscula correspondente
    return re.sub(r'([a-z])([A-Z])', r'\1_\2', nome_coluna).lower()

# Pega os nomes das colunas dinamicamente
colunas_atuais = df.columns

# Aplica a transformação em todos os nomes das colunas
novos_nomes = [transformar_nome_coluna(coluna) for coluna in colunas_atuais]

# Renomeia as colunas do DataFrame
df_renomeado = df.toDF(*novos_nomes)


### Checagem de Dados de Tempo
df = df.withColumn("date", to_date("date", "yyyy-MM-dd"))


### Salva dados
parquet_output_path = "s3://eedb-015-2025-1-projeto-integrador-grupo-c-nv/trusted/holiday/"

# Salvar o DataFrame como parquet no S3
df.write.mode("overwrite").parquet(parquet_output_path)

print(f"Data saved as parquet to {parquet_output_path}")
