from httplib import HTTPConnection

class SensorsHttp():
    @property
    def server_address(self):
        return self.server.host

    @property
    def server_port(self):
        return str(self.server.port)

    def __init__(self, server_address, server_port):
        self.server = HTTPConnection(host = server_address, port = int(server_port))

    def __connect_to_server(self):
        self.server.connect()

    def __disconnect_from_server(self):
        self.server.close()

    def __get_wt(self, unit):
        self.__connect_to_server()
        self.server.request('GET', "/Single" + str(unit))
        response_string = self.server.getresponse().read()
        temperature = float(response_string.split(";")[-1][:4].replace(",", "."))
        return temperature
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
        