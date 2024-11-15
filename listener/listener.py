import oracledb
from os import environ as env
import time
import sys
import uuid

oracledb.init_oracle_client()

topicName = "my_teq"
consumerName = "my_subscriber"

connection_string = env.get("DB_CONNECTION_STRING")
user = env.get("DB_USER")
password = env.get("DB_PASSWORD")
connection = oracledb.connect(dsn=connection_string,user=user,password=password)

jmsType = connection.gettype("SYS.AQ$_JMS_TEXT_MESSAGE")
headerType = connection.gettype("SYS.AQ$_JMS_HEADER")
userPropType = connection.gettype("SYS.AQ$_JMS_USERPROPARRAY")


queue = connection.queue(topicName, jmsType)
queue.deqOptions.consumername = consumerName

print("starting...")
while True: 
    messages = queue.deqmany(5)
    for message in messages:
        filename = "/app/results/" + str(uuid.uuid4()) + ".json"
        with open (
            filename, "w"
        ) as handler:
            handler.write(str(message.payload.TEXT_VC))
    connection.commit()
    time.sleep(1) 
