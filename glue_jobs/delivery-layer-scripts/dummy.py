from pyspark.sql import SparkSession
import time


spark = SparkSession.builder.appName("dummy-job").getOrCreate()

print("Iniciando job dummy...")
print("Job PySpark em execução (sem transformação real)...")

time.sleep(3)

print("Job dummy finalizado com sucesso.")


spark.stop()