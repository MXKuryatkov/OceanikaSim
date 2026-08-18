import time
from user.library import DroneLibrary
drone = DroneLibrary()

drone.start()
drone.set_speed(50.0)
time.sleep(4.0)
drone.set_course(180.0)

drone.stop()