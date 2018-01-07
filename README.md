# FPGA-ultrasonic-radar
Verilog implementation of a ultrasonic radar

## Description 

![Full](https://github.com/bryonkucharski/FPGA-ultrasonic-radar/blob/master/images/full.jpg)

I used an ultrasonic proximity sensor attached to a servo to scan in three directions: left, center, and right. The sensor detected objects at a max of 200cm and displayed the objects on the VGA Screen. Any objects not detected by the sensor will not be displayed on the screen. A pulse is played out of a speaker based on the distance of the objects.

## Overview of Modules 

top – This module connects all other modules together and changes the overall state of the program. Each state change either turns the servo or gets a new value from the ultrasonicSensor module. It also displays the distance from the sensor on the 7 segment displays

ultrasonicSensor - This module is responsible for calculating the distance in centimeters and outputs the distance (in cm) whenever the enable is high. 

sound – this module outputs a C6 note for the given period of time and outputs no note for the same period of time. The period of time is given to module based on the distance from the ultrasonic sensor.

DrawRadar – Handles all of the drawing on the VGA
PwmGenerator.v – Generates the PWM signal to control the servo at 0, 90, or 180 degrees

## Images

State Machine
![StateMachine](https://github.com/bryonkucharski/FPGA-ultrasonic-radar/blob/master/images/blockdiagram.png)

Technical Diagram 
![TechnicalDiagram](https://github.com/bryonkucharski/FPGA-ultrasonic-radar/blob/master/images/technicaldiagram.png)

VGA
![VGA](https://github.com/bryonkucharski/FPGA-ultrasonic-radar/blob/master/images/vga.jpg)


