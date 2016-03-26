from sensors_actuators_k004b.sensors_modbus import SensorsModbus
from sensors_actuators_k004b.actuators_modbus import ActuatorsModbus
from sensors_actuators_k004b.sensors_http import SensorsHttp

import numpy as np
import time
import os

sensor_client_address = os.environ["EX9132_ADDRESS"]
sensor_client_port = os.environ["EX9132_PORT_1"]

actuator_client_address = os.environ["EX9132_ADDRESS"]
actuator_client_port = os.environ["EX9132_PORT_2"]

sensor_server_address = os.environ["WT_ADDRESS"]
sensor_server_port = os.environ["WT_PORT"]

am = ActuatorsModbus(actuator_client_address, actuator_client_port)
sm = SensorsModbus(sensor_client_address, sensor_client_port)
sh = SensorsHttp(sensor_server_address, sensor_server_port)

for k in np.linspace(0.15,0.6,46):
    
    opening_level = k

    am.set_ex9024(opening_level = opening_level)
    
    t_start= time.time()

    while time.time()- t_start < 60:
      
        flowrate = sm.get_mc602_flowrate()
        temperature_inlet = sm.get_mc602_temperature_inlet()
        temperature_outlet = sm.get_mc602_temperature_outlet()
        ex9024_level = am.get_ex9024()

        rtm1_0 = sm.get_rtm1_0()
        rtm1_1 = sm.get_rtm1_1()

        wt_0 = sh.get_wt_0()
        wt_1 = sh.get_wt_1()
        wt_2 = sh.get_wt_2()
        wt_3 = sh.get_wt_3()
        
        data_set = [time.ctime(), flowrate, temperature_inlet, temperature_outlet, round(ex9024_level,2), rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3]
      
        print data_set

        for data_element in data_set:
            
            with open("calibration_actuator_with_cooldown.csv", "a") as f:
                f.write(str(data_element) + ", ")
        with open("calibration_actuator_with_cooldown.csv", "a") as f:
            f.write("\n")

        time.sleep(1.0)

am.set_ex9024(opening_level = 0)

try:

    while True:

            flowrate = sm.get_mc602_flowrate()
            temperature_inlet = sm.get_mc602_temperature_inlet()
            temperature_outlet = sm.get_mc602_temperature_outlet()
            ex9024_level = am.get_ex9024()

            rtm1_0 = sm.get_rtm1_0()
            rtm1_1 = sm.get_rtm1_1()

            wt_0 = sh.get_wt_0()
            wt_1 = sh.get_wt_1()
            wt_2 = sh.get_wt_2()
            wt_3 = sh.get_wt_3()
            
            data_set = [time.ctime(), flowrate, temperature_inlet, temperature_outlet, round(ex9024_level,1), rtm1_0, rtm1_1, wt_0, wt_1, wt_2, wt_3]

            print data_set

            for data_element in data_set:
                
                with open("calibration_actuator_with_cooldown.csv", "a") as f:
                    f.write(str(data_element) + ", ")
            with open("calibration_actuator_with_cooldown.csv", "a") as f:
                f.write("\n")

            time.sleep(1.5)


except KeyboardInterrupt:

    sm.disconnect_from_client()
    am.disconnect_from_client()

    raise
