from pymodelica import compile_fmu
room_fmu = compile_fmu('room_model_backup.RoomRadiator', '/home/hc/jmtest/room_model_backup.mo')
from pymodelica import compile_jmu
room_jmu=compile_jmu('room_model_backup.RoomRadiator', '/home/hc/jmtest/room_model_backup.mo')

from pyfmi import load_fmu

modsim = load_fmu(room_fmu)
# modsim.simulate()
from pyjmi import transfer_optimization_problem

opt_prob = transfer_optimization_problem('room_model_backup.RoomRadiator', '/home/hc/jmtest/room_model_backup.mo', accept_model=True)