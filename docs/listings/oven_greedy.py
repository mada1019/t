# Benoetigte packages bzw classes
from sensors_actuators_k004b.sensors_modbus import SensorsModbus
from sensors_actuators_k004b.sensors_http import SensorsHttp
from sensors_actuators_k004b.actuators_modbus import ActuatorsModbus
import time
import os
import numpy as np

# Modbus Connection Parameter - Port 1 Sensor, Port 2 Actuator
sensor_client_address = os.environ["EX9132_ADDRESS"]
sensor_client_port = os.environ["EX9132_PORT_1"]
actuator_client_address = os.environ["EX9132_ADDRESS"]
actuator_client_port = os.environ["EX9132_PORT_2"]

# http Connection Parameter
server_address = os.environ["WT_ADDRESS"]
server_port = os.environ["WT_PORT"]

#Infozwecke
#print server_address
#print server_port 

sm = SensorsModbus(sensor_client_address, sensor_client_port)
am = ActuatorsModbus(actuator_client_address, actuator_client_port)
sh = SensorsHttp(server_address, server_port)
valve_open = 1.0
valve_closed = 0.0



# Rudimentaere Steuerung

try:

    while True:

        rtm1_0 = sm.get_rtm1_0()
        rtm1_1 = sm.get_rtm1_1()

        ex9024_level = am.get_ex9024()

        wt_0 = sh.get_wt_0()
        wt_1 = sh.get_wt_1()
        wt_2 = sh.get_wt_2()
        wt_3 = sh.get_wt_3()
        
        temperatures = [rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3]

        weightings = [1, 1, 1, 1, 1, 1]

        temperatures_weighted = 0

        for j, temperature in enumerate(temperatures):

            temperatures_weighted += weightings[j] * temperature

        temperature_room = temperatures_weighted / sum(weightings)

        # print temperatures
        # print temperature_room

        # print "loop end"


        if (temperature_room < 20.0) and (abs(ex9024_level-valve_open) > 0.05):
            
            print "too cold"

            am.set_ex9024(opening_level = valve_open)

        elif (temperature_room > 21.5) and (abs(ex9024_level-valve_closed) > 0.05):

            print "too hot!"

            am.set_ex9024(opening_level = valve_closed)
        
        data_set = [time.ctime(), rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3, round(temperature_room, 2), ex9024_level]

        print data_set

        for data_element in data_set:
            
            with open("measurement_oven_greedy_1.csv", "a") as f:
                f.write(str(data_element) + ", ")

        with open("measurement_oven_greedy_1.csv", "a") as f:
            f.write("\n")
        
        # Abfrage-/Updaterythmus der Steuerung
        time.sleep(60.0)


except KeyboardInterrupt:

    sm.disconnect_from_client()
    am.disconnect_from_client()

    raise
