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

	headlight::On();
	Wait(10.0);
	headlight::Off();

	bot::MotorDisable();
}