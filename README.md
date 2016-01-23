# Arduino-Smooth-and-accurate-Microstepping-with-Stepper-Motor
This code will enable a simple Arduino Uno to Microstep a stepper motor with help from a motor driver.
This code require NO LIBRARY or any special fucntion of coding. It's based mostly on physics and calculation to make it this smooth.

Wiring would be similar to this attached liink below<br />
http://cdn.instructables.com/FUM/EFGU/HRI8UMM7/FUMEFGUHRI8UMM7.LARGE.jpg<br />
DISCLAIMER : The picture in the link are not my creation, and I have no right to calim it as mine.

My configuration is similar to that. 4 pin stepper motor -> driver -> arduino uno.
The wiring for this project is not done by me, so I will update it soon after further study.

In this code, Arduino will be responsible to control the pulse frequency and give it to motor driver.
Later in this code, you will see theat I only manipulate the delay between steps to increase or decrease my motor speed.
More detail can be seen in the code.

Thanks for reading my first "properly-uploaded-code" if anyone want to contribute or request a pull, please feel free to ask :)

Gerator
