# -*- coding: utf-8 -*-

from serial import Serial
from time import sleep

import logging
logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

class SensorsRS232():

    _max_retries_initialized_communication = 10

    @property
    def max_retries_initialized_communication(self):

        return self._max_retries_initialized_communication


    def open_serial_port(self):

        # Test whether the port got opened automatically, and if not,
        # open it explicitly

        logging.debug("Checking whether serial port " + \
            self.serial_connection.port + " is already open ...")

        if not self.serial_connection.isOpen():

            logging.debug("Attempting to open serial port " + \
                self.serial_connection.port + " ...")

            self.serial_connection.open()

        logging.debug("Serial port " + \
            self.serial_connection.port + " is open")


    def close_serial_port(self):

        logging.debug("Attempting to close serial port " + \
            self.serial_connection.port + " ...")

        self.serial_connection.close()

        logging.debug("Serial port " + \
            self.serial_connection.port + " closed")


    def __init__(self, port, baudrate, parity, stopbits, bytesize, timeout):

        self.serial_connection = Serial( \
            port = port, \
            baudrate = int(baudrate), \
            parity = parity, \
            stopbits = int(stopbits), \
            bytesize = int(bytesize), \
            timeout = float(timeout))

        self.open_serial_port()


    def __del__(self):

        self.close_serial_port()


    def __get_spn1(self, command):

        # Initialize communication by sending "R"; if the SPN1 returns
        # "»" (ascii charatcer number 175) a further command can be send,
        # see appendix B of the SPN1 handbook for further information
        # and for a list of available commands

        k = 0

        while k < self._max_retries_initialized_communication:

            logging.debug("Initilalizing communication with SPN1 over " + \
                self.serial_connection.port + " ...")
            self.serial_connection.write("R")
            r_response = self.serial_connection.readline()

            if not r_response == chr(175):

                logging.error("Initilalizing communication with SPN1 failed, " + \
                    "trying again in 1.0 seconds ...")

                k += 1
                sleep(1.0)

            else:

                logging.debug("Communication initialized, sending command " + \
                    command + " to " + self.serial_connection.port + " ...")
                self.serial_connection.write(command)
                logging.debug("Command successfully sent")

                logging.debug("Attempting to read response line from " + \
                    self.serial_connection.port + " ...")
                command_response = self.serial_connection.readline()
                logging.debug("Response line received")

                logging.debug("Processing received data ...")

                try:
                    spn1_measurements = map(float, command_response[1:-1].split(","))
                    logging.debug("Received data successfully processed")

                    return spn1_measurements

                except ValueError:
                    logging.error("Error processing recieved data: " + \
                        command_response + \
                        ", trying again to geet a valid response ...")

        if k == self.max_retries_initialized_communication:

            logging.error("Failed to communicate with SPN1")


    def get_spn1_all_measurements(self):

        return self.__get_spn1("S")


    def get_spn1_total_radiation(self):

        return self.__get_spn1("S")[0]


    def get_spn1_diffuse_radiation(self):

        return self.__get_spn1("S")[1]


    def get_spn1_sunshine_presence(self):

        return self.__get_spn1("S")[2]
