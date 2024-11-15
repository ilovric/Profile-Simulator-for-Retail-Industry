import oracledb
import time
from os import environ as env
from random import randrange

oracledb.init_oracle_client()

connection_string = env.get("DB_CONNECTION_STRING")
user = env.get("DB_USER")
password = env.get("DB_PASSWORD")
connection = oracledb.connect(dsn=connection_string,user=user,password=password)

cursor = connection.cursor()

print("starting...", flush=True)
while True: 
    cursor.callproc("generate_profile")
    time.sleep(randrange(5)) 
