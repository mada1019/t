from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.constants import Endian
from pymodbus.payload import BinaryPayloadDecoder

from actuators_modbus import ActuatorsModbus

class Actuators():


    def set_valve_position(self,opening_level):

        return self.actuators_modbus.set_ex9024(opening_level)


    def get_valve_position(self):

        return self.actuators_modbus.get_ex9024()       

 
    def test_all(self):

        self.set_valve_position(opening_level=0.0)
        self.get_valve_position()


    def __init__(self, client_address, client_port):

        self.actuators_modbus = ActuatorsModbus(client_address, client_port)

