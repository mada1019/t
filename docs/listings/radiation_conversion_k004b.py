from pysolar.solar import *
from pysolar import *
import datetime
from math import cos, sin, radians
import numpy as np

latitude_deg = 49.01305
longitude_deg = 8.39207     # Negativ Richtung Westen gemessen von Greenwich, England aus
elevation = 116.0
beta = 8.0      # Ausrichtung der Flaeche in Bodenebene. Norden ist Nullpunkt mit positiver Richtung im Uhrzeigersinn

data = np.loadtxt("globalstrahlung.csv", delimiter = ",")

t_start = datetime.datetime(year,month,day,hour,minute)
timemeasure = np.asarray([t_start + datetime.timedelta(minutes=(distance_measurements*dt)) for dt in range(data.size)])

qdotmeasure = data
qdotsun_effective_list = []
azimuth_list = []
altitude_list = []

for i in range(data.size):

    azimuth = get_azimuth(latitude_deg, longitude_deg, timemeasure[i], elevation)
    altitude = get_altitude(latitude_deg, longitude_deg, timemeasure[i], elevation)

    if (altitude <= 0.0) or (beta - 270 <= azimuth <= beta - 90.0) or (altitude == 90.0):
        # Sonne noch nicht aufgegangen 
        # oder Flache verschattet
        qdotsun_effective = 0.0

    elif (qmeasure[i] > 0.0) and (0.0 < altitude < 5.0):
        # Vermeide unrealistisch hohe Strahlungsintensitäten bei niedrigem Sonnenhöhenwinkel
        qdotsun_effective = 10.0

    else:
        qdotsun_effective = qdotmeasure[i] * cos(radians(azimuth - beta)) * (cos(radians(altitude))/sin(radians(altitude)))

    azimuth_list.append(azimuth)
    altitude_list.append(altitude)
    qdotsun_effective_list.append(qdotsun_effective)

np.savetxt("qdotsun_effective.csv", np.c_[np.asarray(qdotsun_effective_list), delimiter=",")