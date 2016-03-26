from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from modbus_connection import ModbusConnection
from pymodbus.constants import Endian
from pymodbus.payload import BinaryPayloadDecoder

class SensorsModbus(ModbusConnection):
    def __get_mc602(self, address):
            registers = self.read_input_registers(address = address, count = 2, unit = 65)
            decoder = BinaryPayloadDecoder.fromRegisters(registers, endian = Endian.Little)
            float_value = decoder.decode_32bit_float()
            return float_value

    def __get_rtm1(self, unit):
            registers = self.read_input_registers(address = 0, count = 1, unit = unit)
            temperature = registers[0] / 10.0
            return temperature

    def get_mc602_temperature_inlet(self):
        return self.__get_mc602(address = 16)

    def get_mc602_temperature_outlet(self):
        return self.__get_mc602(address = 20)

    def get_mc602_flowrate(self):
        return self.__get_mc602(address = 4)

    def get_rtm1_0(self):
        return self.__get_rtm1(unit = 3)

    def get_rtm1_1(self):
        return self.__get_rtm1(unit = 4)
