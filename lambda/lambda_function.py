import json
import urllib.request
import boto3
import datetime


s3 = boto3.client('s3')

# Nome do bucket
S3_BUCKET = "eedb-015-2025-1-projeto-integrador-grupo-c"

def lambda_handler(event, context):
    # print("Executou o lambda")
    try:
        # Captura os parâmetros de data do evento
        # data_inicio_str = event.get("data_inicio")  # Exemplo: "2023-05-01"
        # data_fim_str = event.get("data_fim")  # Exemplo: "2024-02-01" (opcional)
        data_inicio_str = "2024-01-01"
        data_fim_str = "2025-01-01"

        if not data_inicio_str:
            return {"status": "erro", "message": "Parâmetro 'data_inicio' é obrigatório no formato YYYY-MM-DD"}

        # Converte as datas para objetos datetime
        data_inicio = datetime.datetime.strptime(data_inicio_str, "%Y-%m-%d").date()

        if data_fim_str:
            data_fim = datetime.datetime.strptime(data_fim_str, "%Y-%m-%d").date()
        else:
            data_fim = datetime.date.today()  # Assume a data atual se não for informada

        # Verifica se a data início é menor que a data fim
        if data_inicio > data_fim:
            return {"status": "erro", "message": "A 'data_inicio' não pode ser maior que a 'data_fim'"}

        # Criar uma lista de meses dentro do intervalo desejado
        data_corrente = data_inicio
        meses_processados = []
        anos_processados = set()

        while data_corrente <= data_fim:
            ano = data_corrente.year
            mes = f"{data_corrente.month:02d}"  # Formata o mês com dois dígitos

            meses_processados.append((ano, mes))
            anos_processados.add(ano)

            # Avança para o próximo mês
            if data_corrente.month == 12:
                data_corrente = datetime.date(ano + 1, 1, 1)
            else:
                data_corrente = datetime.date(ano, data_corrente.month + 1, 1)

        # 🔹 **Baixar e salvar os dados de táxi para cada mês**
        for ano, mes in meses_processados:
            try:
                temp_file_taxi = f"/tmp/yellow_tripdata_{ano}-{mes}.parquet"
                S3_KEY_TAXI = f"raw/taxi/yellow_tripdata_{ano}-{mes}.parquet"
                FILE_URL_TAXI = f"https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{ano}-{mes}.parquet"

                urllib.request.urlretrieve(FILE_URL_TAXI, temp_file_taxi)
                s3.upload_file(temp_file_taxi, S3_BUCKET, S3_KEY_TAXI)

                print(f"Arquivo de táxi {ano}-{mes} salvo em S3.")

            except Exception as e:
                print(f"Erro ao processar táxi {ano}-{mes}: {str(e)}")

        # 🔹 **Baixar e salvar os feriados para cada ano**
        for ano in anos_processados:
            try:
                temp_file_holiday = f"/tmp/public_holidays_{ano}.json"
                S3_KEY_HOLIDAY = f"raw/holiday/public_holidays_{ano}.json"
                FILE_URL_HOLIDAY = f"https://date.nager.at/api/v3/PublicHolidays/{ano}/US"

                response = urllib.request.urlopen(FILE_URL_HOLIDAY)
                holidays_data = response.read().decode()

                with open(temp_file_holiday, "w") as file:
                    file.write(holidays_data)

                s3.upload_file(temp_file_holiday, S3_BUCKET, S3_KEY_HOLIDAY)
                print(f"Feriados de {ano} salvos em S3.")

            except Exception as e:
                print(f"Erro ao processar feriados de {ano}: {str(e)}")

        return {
            "status": "sucesso",
            "message": f"Arquivos de táxi e feriados salvos de {data_inicio_str} até {data_fim_str or 'hoje'}"
        }

    except Exception as e:
        return {"status": "erro", "message": str(e)}

