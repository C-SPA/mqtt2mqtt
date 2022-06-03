# pip3 install pandas
# pip3 install paho-mqtt
import glob
import os
import csv, json, sys, random, time 
import pandas as pd
from paho.mqtt import client as mqtt_client
#mosquitto_sub -h cfsr.bse.vt.edu -t usdajson -u usdadev -P U5DAPa55

broker = 'cfsr.bse.vt.edu'
port = 1883
topic = "usdajson"
# generate client ID with pub prefix randomly
client_id = f'python-mqtt-{random.randint(0, 1000)}'
username = 'usdadev'
password = 'U5DAPa55'

def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code %d\n", rc)

    client = mqtt_client.Client(client_id)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client

def publish(client,mqttmsg):
    time.sleep(1)
    msg = f"[{mqttmsg}]"
    result = client.publish(topic, msg)
    # result: [0, 1]
    status = result[0]
    if status == 0:
        print(f"Send `{msg}` to topic `{topic}`")
    else:
        print(f"Failed to send message to topic {topic}")

list_of_files = glob.glob('C:/Campbellsci/LoggerNet/CR*.dat') # Shall we put the base name into the regex?
latest_file = max(list_of_files, key=os.path.getctime)
skipHeaderDf =pd.read_csv(latest_file, skiprows=[0,2,3])

result = skipHeaderDf.to_json(orient="split")
parsed = json.loads(result)
mqttmsg=json.dumps(parsed, indent=4)
print(mqttmsg)
client = connect_mqtt()
client.loop_start()
publish(client,mqttmsg)
