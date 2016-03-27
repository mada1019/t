from actuators_modbus import ActuatorsModbus
from httplib import HTTPConnection
from sensors_modbus import SensorsModbus
from sensors_http import SensorsHttp

class Actuators():

    def __init__(self, client_address, client_port):
        self.actuators_modbus = ActuatorsModbus(client_address, client_port)

    def set_valve_position(self,opening_level):
        return self.actuators_modbus.set_ex9024(opening_level)

    def get_valve_position(self):
        return self.actuators_modbus.get_ex9024()       

class Sensors():

    def __init__(self, client_address, client_port, server_address, server_port, port, baudrate, parity, stopbits, bytesize, timeout):
        self.sensors_modbus = SensorsModbus(client_address, client_port)
        self.sensors_http = SensorsHttp(server_address, server_port)

    def get_temperature_northeast(self):
        return self.sensors_modbus.get_rtm1_0()

    def get_temperature_northwest(self):
        return self.sensors_http.get_wt_3()

    def get_temperature_west(self):
        return self.sensors_http.get_wt_2()

    def get_temperature_southwest(self):
        return self.sensors_modbus.get_rtm1_1()

    def get_temperature_southeast(self):
        return self.sensors_http.get_wt_0()

    def get_temperature_east(self):
        return self.sensors_http.get_wt_1()

    def get_radiator_flowrate(self):
        return self.sensors_modbus.get_mc602_flowrate()

    def get_radiator_temperature_inlet(self):
        return self.sensors_modbus.get_mc602_temperature_inlet()

    def get_radiator_temperature_outlet(self):
        return self.sensors_modbus.get_mc602_temperature_outlet()