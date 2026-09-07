#include <Piranha.h>

void DroneSetup(void)
{
	
}

void DroneLoop(void)
{
	bot::MotorEnable();
	move::Reset();
	bot::FixCourse();
	bot::FixDepth();
	WaitMs(500);

	move::Forward(5.0);
	bot::Stop();

	bot::MotorDisable();
}