import time
from user.library import DroneLibrary
drone = DroneLibrary()

drone.start()
drone.set_depth(20.0)
drone.set_speed(50.0)
time.sleep(3.0)
drone.set_speed(0.0)

drone.stop()