import time
from user.library import DroneLibrary
drone = DroneLibrary()

drone.start()
drone.set_headlight(100.0)
drone.set_depth(30.0)
time.sleep(2.0)
for _ in range(4):
	drone.set_speed(50.0)
	time.sleep(3.0)
	drone.set_speed(0.0)
	drone.change_course(180.0)
	for _ in range(1):
		drone.set_headlight(0.0)
		time.sleep(0.5)
		drone.set_headlight(100.0)
time.sleep(1.0)
drone.set_headlight(0.0)

drone.stop()