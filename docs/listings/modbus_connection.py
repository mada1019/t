from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from time import sleep

class ModbusConnection(object):
    _max_retries_read = 10
    _max_retries_write = 3

    @property
    def max_retries_read(self):
        return self._max_retries_read

    @property
    def max_retries_write(self):
        return self._max_retries_write

    @property
    def client_address(self):
        return self.client.host

    @property
    def client_port(self):
        return str(self.client.port)

    def __init__(self, client_address, client_port):
        self.client = ModbusClient(host = client_address, port = int(client_port))
        self.connect_to_client()

    def __del__(self):
        self.disconnect_from_client()

    def connect_to_client(self):
        self.client.connect()

    def disconnect_from_client(self):
        self.client.close()

    def read_input_registers(self, address, count, unit):
        k = 0
        while k < self.max_retries_read:
            try:
                return self.client.read_input_registers(address = address, count = count, unit = unit).registers
            except:
                k += 1
                sleep(1.5)

    def read_holding_registers(self, address, count, unit):
        k = 0
        while k < self.max_retries_read:
            try:
                return self.client.read_holding_registers(address = address, count = count, unit = unit).registers
            except:
                k += 1
                sleep(1.5)

    def write_register(self, address, unit, value):
        k = 0
        while k < self.max_retries_write:
            try:
                return self.client.write_register(address = address, unit = unit, value = value)
            except:
                k += 1
                sleep(1.5)
