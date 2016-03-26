# Benoetigte packages bzw classes
#from sensors_actuators_k004b.sensors_modbus import SensorsModbus
#from sensors_actuators_k004b.sensors_http import SensorsHttp
from sensors_actuators_k004b.sensors import Sensors
#from sensors_actuators_k004b.actuators_modbus import ActuatorsModbus
from sensors_actuators_k004b.actuators import Actuators
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

s = Sensors(sensor_client_address, sensor_client_port,server_address, server_port)
a = Actuators(actuator_client_address, actuator_client_port)

valve_open = 1.0
valve_closed = 0.0


# Rudimentaere Steuerung

try:

    while True:

        rtm1_0 = s.get_sensor_1()
        wt_3 = s.get_sensor_2()
        wt_2 = s.get_sensor_3()
        rtm1_1 = s.get_sensor_4()
        wt_0 = s.get_sensor_5()
        wt_1 = s.get_sensor_6()
        
        ex9024_level = a.get_valve_position()

        flowrate = s.get_flowrate()
        temperature_inlet = s.get_temperature_inlet()
        temperature_outlet = s.get_temperature_outlet()

        temperatures = [rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3]

        weightings = [1, 1, 1, 1, 1, 1]

        temperatures_weighted = 0

        for j, temperature in enumerate(temperatures):

            temperatures_weighted += weightings[j] * temperature

        temperature_room = temperatures_weighted / sum(weightings)

        # print temperatures
        # print temperature_room
        # print "loop end"

        if (temperature_room < 21.0) and (abs(ex9024_level-valve_open) > 0.05):
            
            print "too cold"

            a.set_valve_position(opening_level = valve_open)

        elif (temperature_room > 22.0) and (abs(ex9024_level-valve_closed) > 0.05):

            print "too hot!"

            a.set_valve_position(opening_level = valve_closed)
        
        ex9024_level_new = a.get_valve_position()

        data_set = [time.ctime(), flowrate, temperature_inlet, temperature_outlet, ex9024_level_new, rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3, round(temperature_room, 2)]

        print data_set

        for data_element in data_set:
            
            with open("measurement_oven_greedy_warmer_20150111.csv", "a") as f:
                f.write(str(data_element) + ", ")

        with open("measurement_oven_greedy_warmer_20150111.csv", "a") as f:
            f.write("\n")
        
        # Abfrage-/Updaterythmus der Steuerung
        time.sleep(60.0)


except KeyboardInterrupt:

    del s
    del a

    raise
