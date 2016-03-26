from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from modbus_connection import ModbusConnection
from pymodbus.constants import Endian
from pymodbus.payload import BinaryPayloadDecoder

import logging
logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

class SensorsModbus(ModbusConnection):

    def __get_mc602(self, address):

        try:
            logging.debug("Attempting to read from MC602")
            registers = self.read_input_registers( \
                address = address, count = 2, unit = 65)
            logging.debug("Successfully read registers from MC602")
            logging.debug("Attempting to convert registers")

            # registers are encoded in "big endian", however the attribute
            # to convert to a float value in pymodbus therefore is Little
            # (and not Big as expected)! Details in class Constants/Endian

            decoder = BinaryPayloadDecoder.fromRegisters(registers, \
                endian = Endian.Little)
            float_value = decoder.decode_32bit_float()
            logging.debug("Successfully converted registers to float_value")
            
            return float_value

        except:
            logging.error("Failed to read from MC602")


    def __get_rtm1(self, unit):

        try:
            logging.debug("Attempting to read from RTM1 unit " + str(unit))
            registers = self.read_input_registers( \
                address = 0, count = 1, unit = unit)
            logging.debug("Successfully read from RTM1 unit " + str(unit))
            temperature = registers[0] / 10.0

            return temperature

        except:
            logging.error("Failed to read from RTM1 unit " + str(unit))


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
