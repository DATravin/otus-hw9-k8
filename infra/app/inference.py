import findspark

findspark.init()

import os
import sys
# from loguru import logger
from functools import partial
from argparse import ArgumentParser
from pyspark.sql import SparkSession, DataFrame, functions as F
from pyspark.sql.types import IntegerType,LongType,DoubleType,StringType
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.feature import MinMaxScaler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml import Pipeline
from pyspark.ml.functions import vector_to_array
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from pyspark.sql import types as T
from pyspark.sql.types import IntegerType,LongType,DoubleType,StringType,ArrayType
import mlflow
from mlflow.tracking import MlflowClient
import pandas as pd
import numpy as np
from dotenv import load_dotenv

def main():

    spark = SparkSession\
        .builder\
        .appName('Spark ML Research')\
        .getOrCreate()

    print('hello')


    model_uri=f's3://{S3_BUCKET_NAME}/artifacts/1/5c07695864724198969d5f095d04298e/artifacts/models/'

    loaded_model = mlflow.spark.load_model(model_uri)

    th=0.2

    sdf_sample = spark.createDataFrame(pd.DataFrame.from_dict(body5))
    predictions2 = loaded_model.transform(sdf_sample)
    predictions2 = (predictions2
                  .withColumn('probability_arr', vector_to_array('probability'))
                  .withColumn('probability_one', F.col('probability_arr')[1])
                  .withColumn('pred_loc',
                        F.when(F.col('probability_one') >= th, F.lit(1))
                        .otherwise(F.lit(0)))
                  )

    prob_predicted = predictions2.select('probability_one').collect()
    prob_predicted[0][0]

    print(f'result:{prob_predicted[0][0]}')

    return prob_predicted[0][0]


if __name__ == "__main__":

    parser = ArgumentParser()
    load_dotenv()
    # parser.add_argument("--bucket", required=True, help="S3 bucket name")
    # parser.add_argument("--mlflow", required=True, help="Mlflow uri")
    # parser.add_argument("--aws_acc", required=True, help="AWS accses key")
    # parser.add_argument("--aws_sec", required=True, help="AWS secret key")
    # parser.add_argument("--bucket_art", required=True, help="S3 bucket name for artifacts")
    # args = parser.parse_args()
    # bucket_name = args.bucket
    # mlflow_ip = args.mlflow
    # aws_acc = args.aws_acc
    # aws_sec = args.aws_sec
    # temp_bucket_name = args.bucket_art
    #temp_bucket_name = 'cold-s3-bucket'

    # os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'https://storage.yandexcloud.net'
    # os.environ['MLFLOW_TRACKING_URI'] = f'http://{mlflow_ip}:8000'
    # os.environ["AWS_ACCESS_KEY_ID"] = f'{aws_acc}'
    # os.environ["AWS_SECRET_ACCESS_KEY"] = f'{aws_sec}'
    # os.environ["S3_ENDPOINT_URL"] = 'https://storage.yandexcloud.net'
    # os.environ["S3_BUCKET_NAME"] = temp_bucket_name

    os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'https://storage.yandexcloud.net'
    os.environ["S3_ENDPOINT_URL"] = 'https://storage.yandexcloud.net'
    os.environ["AWS_ACCESS_KEY_ID"] = os.getenv('S3_ACCESS_KEY')
    os.environ["AWS_SECRET_ACCESS_KEY"] = os.getenv('S3_SECRET_KEY')
    os.environ["S3_BUCKET_NAME"] = os.getenv('S3_BUCKET_NAME')
    S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')

    body5 = {
        "customer_id":[586598],
        "date_key":['2022-09-30'],
        "terminal_id":[124],
        "tranaction_id":[1778881313],
        "tx_datetime":['2022-09-30 11:34:26'],
        "tx_amount":[18.79],
        "tx_time_seconds":[98105666],
        "tx_time_days":[1135],
        "target":[1],
        "tx_fraud_scenario":[2],
        "term_active_days_7d":[4],
        "term_uniq_customer_7d":[3199],
        "term_amount_50perc":[45.0],
        "term_total_cnt_trans_7d":[4526],
        "term_amount_max":[170.72],
        "term_amount_min":[2.13],
        "term_bad_cnt_trans_7d":[4526],
        "term_avg_amount_in_day_7d":[59959.9025],
        "term_cnt_in_day_7d":[1131.5],
        "term_days_with_bad_trans_7d":[4],
        "cust_active_days_7d":[4],
        "cust_uniq_terminal_7d":[5],
        "cust_amount_50perc":[46.0],
        "cust_amount_max":[94.14],
        "cust_amount_min":[21.38],
        "cust_total_cnt_trans_7d":[12],
        "cust_bad_cnt_trans_7d":[2],
        "cust_avg_amount_in_day_7d":[143.71],
        "cust_cnt_in_day_7d":[3.0],
        "cust_days_with_bad_trans_7d":[2],
        "rel_cust_50perc":[0.338372727619946],
        "sh_bad_trans_per_cust":[0.16666665277777895],
        "sh_bad_trans_per_term":[0.9999999997790543],
        "sh_bad_days_per_cust":[0.49999987500003124],
        "sh_bad_days_per_term":[0.9999997500000625],
        "rel_cust_amount_to_max":[-0.035596481094056054],
        "rel_term_amount_to_max":[0.09881962098096198],

        }

    main()
