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

	move::ChangeDepth(20.0,1.0);
	headlight::On();
	move::Forward(3.0);
	headlight::Off();

	bot::MotorDisable();
}