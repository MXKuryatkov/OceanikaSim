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

	move::ChangeDepth(10.0,1.0);
	headlight::On();
	move::Forward(3.0);
	bot::ResetCourse();
	bot::TurnRight(180.0);
	Wait(2.0);
	bot::ResetCourse();
	bot::FixCourse();
	bot::Forward();
	Wait(3.0);
	bot::Stop();
	headlight::Off();

	bot::MotorDisable();
}