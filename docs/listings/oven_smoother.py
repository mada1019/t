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

sm = SensorsModbus(sensor_client_address, sensor_client_port)
am = ActuatorsModbus(actuator_client_address, actuator_client_port)
sh = SensorsHttp(server_address, server_port)
valve_open = 1.0
valve_light_open = 0.8
valve_medium_open = 0.6
valve_light_closed = 0.4
valve_medium_closed = 0.2
valve_closed = 0.0

# "Weichere/Glattere" Steuerungslogik mit zwei Alternativen

# Auswahl Steuerungsmethodik
# Alternative 1 mit gemittelter Temperatur
# Alternative 2 mit Sensor zaehlen
option = 1

try:

    while True:
        
        rtm1_0 = sm.get_rtm1_0()
        rtm1_1 = sm.get_rtm1_1()

        ex9024_level = am.get_ex9024()

        wt_0 = sh.get_wt_0()
        wt_1 = sh.get_wt_1()
        wt_2 = sh.get_wt_2()
        wt_3 = sh.get_wt_3(
)        
        temperatures = [rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3]

        weightings = [1, 1, 1, 1, 1, 1]

        temperatures_weighted = 0

        for j, temperature in enumerate(temperatures):

            temperatures_weighted += weightings[j] * temperature

        temperature_room = temperatures_weighted / sum(weightings)




        if option==1:

            if (temperature_room < 19.85) and (abs(ex9024_level-valve_open) > 0.05):

                am.set_ex9024(opening_level = valve_open)

            elif (20.15 < temperature_room < 20.35) and (abs(ex9024_level-valve_light_open) > 0.05):

                am.set_ex9024(opening_level = valve_light_open)

            elif (20.65 < temperature_room < 20.85) and (abs(ex9024_level-valve_medium_open) > 0.05):
            
                am.set_ex9024(opening_level = valve_medium_open)

            elif (21.15 < temperature_room < 21.35) and (abs(ex9024_level - valve_light_closed) > 0.05):

                am.set_ex9024(opening_level = valve_light_closed)
            
            elif (22.15 < temperature_room < 22.35) and (abs(ex9024_level-valve_medium_closed) > 0.05):

                am.set_ex9024(opening_level = valve_medium_closed)

            elif (22.65 < temperature_room) and (abs(ex9024_level-valve_closed) > 0.05):        

                am.set_ex9024(opening_level = valve_closed)


        # Sensorzaehlmethodik
        elif option == 2:
            
            interval_0 = sum(1 for item in temperatures if item<20.0)
            
            interval_1 = sum(1 for item in temperatures if 20.0<=item<20.5)
            
            interval_2 = sum(1 for item in temperatures if 20.5<=item<21.0)
            
            interval_3 = sum(1 for item in temperatures if 21.0<=item<21.5)
            
            interval_4 = sum(1 for item in temperatures if 22.5<=item<23.0)
            
            interval_5 = sum(1 for item in temperatures if 23.0<=item)



            if (interval_0>2) and (abs(ex9024_level-valve_open) > 0.05):
                
                am.set_ex9024(opening_level = valve_open)

            elif (interval_1>2) and (abs(ex9024_level-valve_light_open) > 0.05):
                
                am.set_ex9024(opening_level = valve_light_open)
            
            elif (interval_2>2) and (abs(ex9024_level-valve_medium_open) > 0.05):
                
                am.set_ex9024(opening_level = valve_medium_open)

            elif (interval_3>2) and (abs(ex9024_level-valve_light_closed) > 0.05):
            
                am.set_ex9024(opening_level = valve_light_closed)
            
            elif (interval_4>2) and (abs(ex9024_level-valve_medium_closed) > 0.05):
                
                am.set_ex9024(opening_level = valve_medium_closed)
            
            elif (interval_5>2) and (abs(ex9024_level-valve_closed) > 0.05):
            
                am.set_ex9024(opening_level = valve_closed)


        data_set = [time.ctime(), rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3, round(temperature_room, 2), ex9024_level]

        print data_set

        for data_element in data_set:
            
            with open("measurement_oven_smoother_1.csv", "a") as f:
                f.write(str(data_element) + ", ")

        with open("measurement_oven_smoother_1.csv", "a") as f:
            f.write("\n")
        
        # Abfrage/Updaterythmus der Steuerung
        time.sleep(5.0)


except KeyboardInterrupt:

    sm.disconnect_from_client()
    am.disconnect_from_client()

    raise