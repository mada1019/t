from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from modbus_connection import ModbusConnection

import logging
logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

class ActuatorsModbus(ModbusConnection):

    _ex9024_min_register_value = 8191
    _ex9024_max_register_value = 16383


    @property
    def ex9024_min_register_value(self):

        return self._ex9024_min_register_value


    @property
    def ex9024_max_register_value(self):

        return self._ex9024_max_register_value


    def __set_ex9024(self, address, voltage_value):

        register_value = 8191 + 819.2 * voltage_value

        try:
            logging.debug("Attempting to write to EX9024")
            registers = self.write_register( \
                address = address, unit = 8, value = register_value)
            logging.debug("Successfully written EX9024")

            return registers

        except:
            logging.error("Failed to write to EX9024")


    def __get_ex9024(self, address):

        try:
            logging.debug("Attempting to read from EX9024")
            registers = self.read_holding_registers( \
                address = address, count = 1, unit = 8)
            logging.debug("Successfully read from EX9024")

            voltage_value = (float(registers[0])-8191)/819.2
            return voltage_value

        except:
            logging.error("Failed to read from EX9024")
            raise


    def set_ex9024(self, opening_level):

        opening_level = float(opening_level)

        if opening_level < 0 or opening_level > 1:

            raise ValueError('''Only values between 0 and 1 allowed for opening level definition.''')
       
        voltage_value = opening_level * 10

        self.__set_ex9024(address = 2, voltage_value = voltage_value)


    def get_ex9024(self):

        voltage_value = self.__get_ex9024(address = 2)

        opening_level = voltage_value/10.0

        return opening_level

