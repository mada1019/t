from httplib import HTTPConnection

import logging
logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

class SensorsHttp():

    @property
    def server_address(self):

        return self.server.host

    @property
    def server_port(self):

        return str(self.server.port)


    def __init__(self, server_address, server_port):

        self.server = HTTPConnection( \
            host = server_address, port = int(server_port))


    def __connect_to_server(self):

        try:
            logging.debug("Attempting to connect to server " + \
                self.server_address + ":" + self.server_port)

            self.server.connect()

            logging.debug("Successfully connected to server " + \
                self.server_address + ":" + self.server_port)

        except:
            logging.error("Failed to connect to server " + \
                self.server_address + ":" + self.server_port)


    def __disconnect_from_server(self):

        try:
            logging.debug("Attempting to disconnect from server " + \
                self.server_address + ":" + self.server_port)

            self.server.close()
            
            logging.debug("Successfully disconnected from server " + \
                self.server_address + ":" + self.server_port)

        except:
            logging.error("Failed to disconnect from server " + \
                self.server_address + ":" + self.server_port)


    def __get_wt(self, unit):

        self.__connect_to_server()

        try:
            logging.debug("Attempting to read from WT unit " + str(unit))
            self.server.request('GET', "/Single" + str(unit))

            response_string = self.server.getresponse().read()
            logging.debug("Successfully read from WT unit " + str(unit))

            temperature = \
                float(response_string.split(";")[-1][:4].replace(",", "."))
            return temperature

        except:
            logging.error("Failed to read from WT unit " + str(unit))

        finally:
            self.__disconnect_from_server()


    def get_wt_0(self):

        return self.__get_wt(unit = 1)


    def get_wt_1(self):

        return self.__get_wt(unit = 2)


    def get_wt_2(self):

        return self.__get_wt(unit = 3)


    def get_wt_3(self):

        return self.__get_wt(unit = 4)
        