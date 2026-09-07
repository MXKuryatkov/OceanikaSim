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
	for (int i = 0; i < 4; i++) {
		move::Forward(3.0);
		Wait(1.0);
		bot::TurnRight(180.0);
		Wait(2.0);
		bot::ResetCourse();
		bot::FixCourse();
		bot::FixDepth();
	}
	headlight::Off();
	bot::Stop();

	bot::MotorDisable();
}