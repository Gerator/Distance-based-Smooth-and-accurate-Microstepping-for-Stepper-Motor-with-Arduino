//------------------------------------------------------------------------------------------------------------------------------
// This code has been created to move a motor to a certain distance smoothly to lengthen motor and frame/gear/any other part's 
// lifespan. Currently, this code allow a motor to spin maximum 800 RPM while accelerating and decelerating smoothly with
// supirisingly accurate it's distance reach. It consumes more than 80% dynamic memory. (50% of it consist of calculation and
// step distribution logic, 30% of it for Serial communication). Attempted to use pure C coding to ease up arduino work in delay
// control. No luck so far.
//
// To use this code :
// 1. Upload the code to Arduino
// 2. Open Serial Monitor
// 3. Send command according to instruction
//
// NOTE : You will want to change most of the variable because most of the variables and inputs have been made based on the
// machine I working on.
//------------------------------------------------------------------------------------------------------------------------------

#define         D             4.4563                                          //Diameter of shaft or gear in cm
#define         stepNum       1024                                            //Number of cycle that stepper motor need to make 1 revolution. mine is 1024
#define         ss            200                                             //The RPM will change 200 times while accelerating/decelerating between initial speed and max speed
#define         rpm_constant  2                                               //constant to match the actual RPM of motor
#define         rpm_input     800                                             //Max speed in RPM
#define         rpm           rpm_constant*rpm_input    //rpm value that insert to stepper motor

float           pi            = 3.14159265;             //I believe defining it manually will easen the work of arduino
float           stepDis       = pi*D/stepNum;           //Distance thru one step
unsigned long   totalStep;                              //Total step in defined distance
float           Vi            = 30;                     //Initial RPM value

unsigned long   accelStep, decelStep, consStep;         //Length of step for acceleration, deceleration, and constant speed
unsigned long   conslength;                             //Length for constant delay
int             accelLength, decelLength;               //length to change the value of acceleration and deceleration delay
