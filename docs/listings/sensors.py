from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.constants import Endian
from pymodbus.payload import BinaryPayloadDecoder
from httplib import HTTPConnection

from sensors_modbus import SensorsModbus
from sensors_http import SensorsHttp
from sensors_rs232 import SensorsRS232

class Sensors():


    def get_sensor_northeast(self):

        return self.sensors_modbus.get_rtm1_0()


    def get_sensor_northwest(self):

        return self.sensors_http.get_wt_3()


    def get_sensor_west(self):

        return self.sensors_http.get_wt_2()


    def get_sensor_southwest(self):

        return self.sensors_modbus.get_rtm1_1()


    def get_sensor_southeast(self):

        return self.sensors_http.get_wt_0()


    def get_sensor_east(self):

        return self.sensors_http.get_wt_1()


    def get_radiator_flowrate(self):

        return self.sensors_modbus.get_mc602_flowrate()


    def get_radiator_temperature_inlet(self):

        return self.sensors_modbus.get_mc602_temperature_inlet()


    def get_radiator_temperature_outlet(self):

        return self.sensors_modbus.get_mc602_temperature_outlet()


    def get_radiation_total(self):

        return self.sensors_rs232.get_spn1_total_radiation()


    def get_radiation_diffuse(self):

        return self.sensors_rs232.get_spn1_diffuse_radiation()


    def get_sunshine(self):

        return self.sensors_rs232.get_spn1_sunshine_presence()


    def test_all(self):

        self.get_sensor_northwest()
        self.get_sensor_northeast()
        self.get_sensor_east()
        self.get_sensor_west()
        self.get_sensor_southwest()
        self.get_sensor_east()
        self.get_radiator_flowrate()
        self.get_radiator_temperature_inlet()
        self.get_mc602_temperature_outlet()
        self.get_radiation_total()
        self.get_radiation_diffuse()
        self.get_sunshine()


    def __init__(self, client_address, client_port, server_address, server_port, port, baudrate, parity, stopbits, bytesize, timeout):

        self.sensors_modbus = SensorsModbus(client_address, client_port)
        self.sensors_http = SensorsHttp(server_address, server_port)
        self.sensors_rs232 = SensorsRS232(port, baudrate, parity, stopbits, bytesize, timeout)
