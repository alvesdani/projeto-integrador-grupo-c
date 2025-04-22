from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.functions import col, unix_timestamp
from pyspark.sql.functions import lit
from pyspark.sql.functions import col
from functools import reduce
import boto3

# Inicializando o cliente S3
s3_client = boto3.client('s3')

# Criar a Spark Session
spark = SparkSession.builder \
    .appName("Leitura de Parquet") \
    .getOrCreate()
    
# Ler o arquivo Parquet
df = spark.read.parquet("s3://eedb-015-2025-1-grupo-c-projeto-integrador/raw/taxi/")

### Padronizar nomenclatura

# Recuperando os nomes das colunas e aplicando as transformações
new_columns = [
    col_name.lower().replace("id", "_id") for col_name in df.columns
]

# Renomeando as colunas do DataFrame
df = df.toDF(*new_columns)
print(f"Quantidade de registros no início: {df.count()}")

# df.show(5)

### Checagem de Dados de Tempo

# Converting string timestamps to actual datetime
df = df.withColumn("tpep_pickup_datetime", unix_timestamp("tpep_pickup_datetime", "yyyy-MM-dd HH:mm:ss").cast("timestamp"))
df = df.withColumn("tpep_dropoff_datetime", unix_timestamp("tpep_dropoff_datetime", "yyyy-MM-dd HH:mm:ss").cast("timestamp"))

# Verificar se o pickup_datetime é maior que o dropoff_datetime
df_invalid_data = df.filter(col("tpep_pickup_datetime") >= col("tpep_dropoff_datetime"))
df_invalid_data = df_invalid_data.withColumn("Motivo", lit("Registro desconsiderado pela regra Checagem de Dados de Tempo"))
# print(f"Quantidade de registros retirados do dataFrame principal pois o  campo tpep_pickup_datetime é maior ou igual que tpep_dropoff_datetime, fugindo da regra 'Checagem de Dados de Tempo': {df_invalid_data.count()}")

# Filtrar e manter apenas os dados válidos
df = df.filter(col("tpep_pickup_datetime") < col("tpep_dropoff_datetime"))

# print(f"df.count(): {df.count()}")
# print(f"df_invalid_data.count(): {df_invalid_data.count()}")

## Verificação de Formato e Valores de Flags


# Verificar se a coluna 'store_and_fwd_flag' contém apenas os valores 'Y' ou 'N'
df_valid_flags  = df.filter(~(F.col("store_and_fwd_flag").isin("Y", "N")))
df_valid_flags = df_valid_flags.withColumn("Motivo", lit("Registro desconsiderado pela regra Verificação de Formato e Valores de Flags"))
df_invalid_data = df_invalid_data.union(df_valid_flags)

df_null_value = df.filter(F.col("store_and_fwd_flag").isNull()) 
df_null_value = df_null_value.withColumn("Motivo", lit("Registro desconsiderado pela regra Verificação de Formato e Valores de Flags, registros nulos"))
df_invalid_data = df_invalid_data.union(df_null_value)

# print(f"Quantidade de registros retirados do dataFrame principal pois o  campo store_and_fwd_flag Não são nem 'N'nem 'F', fugindo da regra 'Verificação de Formato e Valores de Flags': {df_valid_flags.count()}")

# Filtrar e manter apenas os dados válidos
# df = df.filter(F.col("store_and_fwd_flag").isin("Y", "N") | F.col("store_and_fwd_flag").isNull()) # CAso queira considerar os registros nulos
df = df.filter(F.col("store_and_fwd_flag").isin("Y", "N"))

# print(f"Total de registros no DF principal: {df.count()}")
# print(f"Quantidade de registros Nulos: {df_null_value.count()}")
# print(f"Total de registros que não são: N, Y ou Nulos: {df_valid_flags.count()}")
# print(f"Total de registros descartados: {df_invalid_data.count()}")

### Verificação de Pagamento

valid_payment_types = [1, 2, 3, 4, 5, 6]
# Verifica registros que não foram informados métodos de pagamento
df_invalid_payments = df.filter(~(F.col("payment_type").isin(valid_payment_types)))
df_invalid_payments = df_invalid_payments.withColumn("Motivo", lit("Registro desconsiderado pela regra Verificação de Pagamento, pois o payment_type não foir informado"))
df_invalid_data = df_invalid_data.union(df_invalid_payments)

#Verifica se tem algum registro Nulo
df_null_value = df.filter(F.col("payment_type").isNull()) 

# Filtrar e manter apenas os dados válidos
df = df.filter((F.col("payment_type").isin(valid_payment_types)))

# print(f"Total de registros no DF principal: {df.count()}")
# print(f"Quantidade de registros Nulos: {df_null_value.count()}")
# print(f"Total de registros que não tem o tipo de pagamento: {df_invalid_payments.count()}")
# print(f"Total de registros descartados: {df_invalid_data.count()}")

### Verificar Tipos de Dados - troca os tipos que recebemos deixando a tabela ocupando menos dados

# Garantir que as colunas tenham os tipos de dados corretos
df = df.withColumn("vendor_id", F.col("vendor_id").cast("integer")
                      ).withColumn("tpep_pickup_datetime", F.col("tpep_pickup_datetime").cast("timestamp")
                      ).withColumn("tpep_dropoff_datetime", F.col("tpep_dropoff_datetime").cast("timestamp")
                      ).withColumn("passenger_count", F.col("passenger_count").cast("integer") # antes era long
                      ).withColumn("trip_distance", F.col("trip_distance").cast("float") # antes era double
                      ).withColumn("ratecode_id", F.col("ratecode_id").cast("integer") # antes era long
                      ).withColumn("store_and_fwd_flag", F.col("store_and_fwd_flag").cast("string")
                      ).withColumn("pulocation_id", F.col("pulocation_id").cast("integer")
                      ).withColumn("dolocation_id", F.col("dolocation_id").cast("integer")
                      ).withColumn("payment_type", F.col("payment_type").cast("integer") # antes era long
                      ).withColumn("fare_amount", F.col("fare_amount").cast("float") # antes era double
                      ).withColumn("extra", F.col("extra").cast("float") # antes era double
                      ).withColumn("mta_tax", F.col("mta_tax").cast("float") # antes era double
                      ).withColumn("tip_amount", F.col("tip_amount").cast("float") # antes era double
                      ).withColumn("tolls_amount", F.col("tolls_amount").cast("float") # antes era double
                      ).withColumn("improvement_surcharge", F.col("improvement_surcharge").cast("float") # antes era double
                      ).withColumn("total_amount", F.col("total_amount").cast("float") # antes era double
                      ).withColumn("congestion_surcharge", F.col("congestion_surcharge").cast("float") # antes era double
                      ).withColumn("airport_fee", F.col("airport_fee").cast("float") # antes era double
                      )
## Registros Duplicados

print("Número de registros antes de remover duplicados: ", df.count())

# Contagem das duplicatas por linha
df_with_count = df.groupBy(df.columns).agg(F.count("*").alias("count"))

# Filtrando as duplicatas
df_duplicates = df_with_count.filter("count > 1")
df_duplicates = df_duplicates.drop("count")

#Desconsiderando registros duplicados
df_duplicates = df_duplicates.withColumn("Motivo", lit("Registro desconsiderado pela regra Registros Duplicados."))
df_invalid_data = df_invalid_data.union(df_duplicates)
df = df.dropDuplicates()


print(f"Total de registros no DF principal: {df.count()}")
print(f"Quantidade de registros dupicados: {df_duplicates.count()}")
print(f"Total de registros descartados: {df_invalid_data.count()}")

### Verificação de Valores Negativos em Campos Monetários

# Lista de colunas que não devem ter valores negativos
negative_fields = [
    "fare_amount",
    "tip_amount",
    "improvement_surcharge",
    "congestion_surcharge",
    "airport_fee"
]

# Cria a condição para identificar registros com qualquer valor negativo
negative_condition = " OR ".join([f"{field} < 0" for field in negative_fields])

# Filtrar registros inválidos com valores negativos
df_negative_values = df.filter(negative_condition)
df_negative_values = df_negative_values.withColumn(
    "Motivo", 
    lit("Registro desconsiderado pela regra de Verificação de Valores Negativos em Campos Monetários")
)

# # Adiciona os inválidos ao DataFrame de registros descartados
df_invalid_data = df_invalid_data.union(df_negative_values)

# # Remove do DF principal os registros com valores negativos
df = df.filter(" AND ".join([f"{field} >= 0" for field in negative_fields]))

print(f"Total de registros no DF principal após filtro de valores negativos: {df.count()}")
print(f"Registros com valores negativos descartados: {df_negative_values.count()}")
print(f"Total final de registros descartados: {df_invalid_data.count()}")

parquet_output_path = "s3://eedb-015-2025-1-grupo-c-projeto-integrador/trusted/taxi_travel_records/"

df = df.withColumn("year", F.year("tpep_pickup_datetime")) \
       .withColumn("month", F.month("tpep_pickup_datetime")) \
       .withColumn("day", F.dayofmonth("tpep_pickup_datetime"))

# Salvar o DataFrame como Parquet no S3
df.write.partitionBy("year", "month", "day").mode("overwrite").parquet(parquet_output_path)

print(f"Data saved as Parquet to {parquet_output_path}")
