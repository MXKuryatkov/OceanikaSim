import time
from user.library import DroneLibrary
drone = DroneLibrary()

drone.start()
drone.set_depth(10.0)
drone.set_speed(50.0)
time.sleep(2.0)
drone.set_speed(0.0)

drone.stop()