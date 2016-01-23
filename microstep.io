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

#define         D             4.4563                    //Diameter of shaft or gear in cm
#define         stepNum       1024                      //Number of cycle that stepper motor need to make 1 revolution. mine is 1024
#define         ss            200                       //The RPM will change 200 times while accelerating/decelerating between initial speed and max speed
#define         rpm_constant  2                         //constant to match the actual RPM of motor. Computational RPM and actual is different
#define         rpm_input     800                       //Max speed in RPM
#define         rpm           rpm_constant*rpm_input    //rpm value that insert to stepper motor

float           pi            = 3.14159265;             //I believe defining it manually will easen the work of arduino
float           stepDis       = pi*D/stepNum;           //Distance thru one step
unsigned long   totalStep;                              //Total step in defined distance
float           Vi            = 30;                     //Initial RPM value

unsigned long   accelStep, decelStep, consStep;         //Length of step for acceleration, deceleration, and constant speed
unsigned long   conslength;                             //Length for constant delay
int             accelLength, decelLength;               //length to change the value of acceleration and deceleration delay
unsigned long   s;                                      //variable to define current steps to move
unsigned long   c1=0, c2=0, c3=0;                       //variable to count number of steps taken at accel, decel, and cons
float           accelSpeed;                             //variable to save acceleration speed change
unsigned long   timeDelay[ss];                          //array to store the delay value of all the step
int             v1, v2, v3, v4;                         //empty value to be used for any need to smoothen arduino work
byte            state = 0;                              //used in command() to recognize input
byte            dir = 0;                                //my configuration : LOW = move motor to LEFT ; HIGH = move motor to RIGHT
char            inDir;                                  //user's input for direction
int             distance, inDis;                        //total distance the motor need to cover and variable to hold user's input for distance

void setup() {
  pinMode(5, OUTPUT);                                   //Pin to send pulses
  pinMode(9, OUTPUT);                                   //Pin to determine direction of motor spin
  Serial.begin(9600);
  Serial.println("Thanks for using Gerator's Motor Driver Program!!!");    //just a small credit for myself if you will :)
  delay(500);
}

void loop() {
  start();
}

void start() {
  command();
  accelerate();
  constant();
  decelerate();
  stopping();
}

void rotate(unsigned long i) {
  PORTD |= _BV(PD5);
  delayMicroseconds(i);
  PORTD &= ~_BV(PD5);
  delayMicroseconds(i);
}

void accelerate() {
  for(int i=0 ; i<ss ; i++) {
    accelSpeed = ((rpm/(1+exp((5-(i/15))/1.6)))+Vi);    //An S-curved equation which you can try in excel to see the RPM curve. Try to change it's constant to adjust your need.
    timeDelay[i] = 60/(stepNum*accelSpeed)*1e6;         //RPM to time delay conversion. This array will determine the movement of motor
    delay(20);                                          //A slight delay to allow arduino to recover
  }
  for(int i=0 ; i<ss ; i++) {
    v1=i;
    v2=timeDelay[v1];                                   //Not sure if it will actually smoothen the movement. My friend suggested it
    for(s=0 ; s<accelLength ; s++) {
      rotate(v2);
      c1++;
      //Serial.println(c1);                               //uncomment this to see steps in accel phase
    }
  }
}
void constant() {
  for(s=0 ; s<consLength ; s++) {
    rotate(v2);
    c2++;
    //Serial.println(c2);                                 //uncomment this to see steps in const phase
  }
}
void deceleate() {
  for(int i=ss-1 ; i>=0 ; i--) {
    v3=i;
    v4=timeDelay[v3];
    for(s=0 ; s<decelLength ; s++) {
    rotate(v4);
    c3++;
    //Serial.println(c3);                                 //uncomment this to see steps in decel phase
    }
  }
}
void stopping() {
  for(s=0 ; s<(totalStep-c1-c2-c3) ; s++) {
    rotate(v4);                                           //movement correction in case of any step arduino miss
  }
  Serial.print("totalStep : ");
  Serial.print(totalStep);
  Serial.print(" | step done A = ");
  Serial.print(c1);
  Serial.print(" ; C = ");
  Serial.print(c2);
  Serial.print(" ; D = ");
  Serial.print(c3);
  Serial.print(" | missing step : ");
  Serial.println(totalStep-c1-c2-c3);
  c1=0;
  c2=0;
  c3=0;
  state=0;
  Serial.println("Done");
  Serial.println();
}
void condition() {
  if(totalStep >= 17600) {
    accelStep = 8800;                                     //It's recommended for accelStep to be multiplication of ss. 8800 is the minimal step needed to keep the motor smooth
    decelStep = 8800;
    consStep = totalStep-(accelStep+decelStep);           //length of step for constant speed
  } else if (totalStep>10000 && totalStep<17600) {
    accelStep = totalStep/2;
    decelStep = totalStep/2;
    consStep = 0;
  } else {
    accelStep = 0;
    decelStep = 0;
    consStep = 0;
    Serial.println("Error dalam perhitungan step motor. Mohon memasukkan jarak tempuh lebih dari 20cm untuk keamanan motor dan rangka");
  }
  accelLength = accelStep/ss;
  consLength = consStep;
  decelLength = decelStep/ss;
}
void command() {
  Serial.println("Please input the direction of our motor move");
  Serial.println("Type 'L' to move to LEFT, 'R' to move to 'RIGHT'");
  while(state==0) {
    if(Serial.available()) {
      inDir = Serial.read();
      if (inDir == 'L') {
        dir = LOW;
        Serial.println("Chosen direction : LEFT");
        state++;
      } else if(inDir == 'R') {
        dir = HIGH;
        Serial.println("Chosen direction : RIGHT");
        state++;
      } else {
        Serial.println("No valid direction chosen, please reinput");
      }
    }
  }
  Serial.println();
  Serial.println("Please input desired distance to travel in cm (min : 20, max : 500). Insert '0' to change direction.");
  while(state==1) {
    if(Serial.available()) {
      inDis = Serial.parseInt();
      if(inDis == 0); {
        state = 0;
        command();
      } else if (inDis<20 || inDis>500) {
        Serial.println("Input is out of distance range, please re-enter the distance (min : 20, max : 500)");
      } else {
        distance = inDis;
        Serial.print("Chosen distance : ");
        Serila.print(inDis);
        Serial.println(" cm");
        state++;
      }
    }
  }
  Serial.println("Processing...");
  Serial.println();
  digitalWrite(9,dir);
  totalStep = distance*7.5/stepDis;                             //7.5 is my gearbox ratio... 7.5 rev to make 1 rev in machine
  condition();
}
