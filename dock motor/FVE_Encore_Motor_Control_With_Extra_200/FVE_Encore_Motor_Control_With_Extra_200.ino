//#include <Time.h>
//#include <TimeLib.h>

// ConstantSpeed.pde
// -*- mode: C++ -*-
//
// Shows how to run AccelStepper in the simplest,
// fixed speed mode with no accelerations
/// \author  Mike McCauley (mikem@open.com.au)
// Copyright (C) 2009 Mike McCauley
// $Id: ConstantSpeed.pde,v 1.1 2011/01/05 01:51:01 mikem Exp mikem $

#include <AccelStepper.h>

AccelStepper stepper; // Defaults to AccelStepper::FULL4WIRE (4 pins) on 2, 3, 4, 5

int state = 1; // 0 = stop, 1 = frequency change, 2 = amplitude change

long starttime = 0;
long endtime = 0;

float Hz_entered = .15; // frequency entered in Hz
String readstring = "";
const float steps_per_rev = 1600; // change if the number of revs changes
const float gear_ratio = 12.5; // gear ratio for our system
//const float  = 1/0.92; // error from testing
const float max_amplitude = .2; // bounding
float stepperspeed = (Hz_entered)*steps_per_rev*gear_ratio; // how many steps per second to achieve a given platform frequency
float amplitude_entered = .2; // bounding
float steps_per_amplitude = steps_per_rev*gear_ratio * (amplitude_entered/max_amplitude)/2; // number of steps to move the platform a given distance
float temp = 0.0; 
long step_pos = 0; // what step we're on
long prev_state = 0; // what state we used to be in

void setup()
{  
   stepper.setMaxSpeed(60000);
   stepper.setSpeed(375);  
   pinMode(6,OUTPUT);
   pinMode(7,OUTPUT);
   Serial.begin(9600);

  
   stepper.setSpeed(stepperspeed);
   Serial.println("Please enter a value between .150 and .300 for frequency.");
   Serial.print("Current frequency is: ");
   Serial.print(Hz_entered);
   Serial.println("Hz"); 
   Serial.print("Current amplitude is: ");
   Serial.print(amplitude_entered);
   Serial.println("meters"); 
   
}

void loop()
{  
//  long starttime = millis(); // not in use now, but may be later
  //long endtime = starttime;
  while(Serial.available())
  {
    char c = Serial.read();
    readstring += c;
    delay(2);
    if(c == 'p')
    { // pause
      if(state>0)
      {        
        prev_state = state;
        state = 0;
       }
      else
      {
        state = prev_state;
      }
      readstring = "";
    }
    if(c=='a')
    { //set to amplitude reading
      Serial.println("Please enter a value between .1 and .2");
       Serial.print("Current amplitude is: ");
       Serial.print(amplitude_entered);
       Serial.println("meters");
       state = 2;
       readstring = "";
    }
    if(c=='f')
    { // set to frequency reading
      Serial.println("Please enter a value between .15 and .3");
      Serial.print("Current frequency is: ");
      Serial.print(Hz_entered);
      Serial.println("Hz");
      state = 1;
      readstring = "";
    }
    if(c=='r')
    { // reset to 0 meters and stop
        prev_state = state;
        state = 0;
        if(amplitude_entered<=.199)
        {
          resetStepper(90);
        }
        else
        {
          resetStepper(0);
        }
        if(stepper.speed()<1)
        {
          stepper.setSpeed(stepper.speed()*-1);
        }
        readstring = "";
    }
  }

  if(readstring.length()>0)
  {
    Serial.println(readstring);
    if(state == 1)
    {
      Hz_entered = readstring.toFloat();
      if(Hz_entered >= .1499 && Hz_entered <= .300)
      {
        resetStepper(90);
        stepperspeed = (Hz_entered)*steps_per_rev*gear_ratio;
        stepper.setSpeed(stepperspeed);
        Serial.print("Frequency changed to ");
        Serial.print(Hz_entered);
        Serial.println("Hz");
      }
      else  
      {
        Serial.println("Out of bounds error 1"); // these trigger even if the readstring is empty.  Not positive why
      }
    }
    if(state == 2)
    {
      temp = readstring.toFloat();
      if(temp >= .099 && temp <= .200)
      {
        amplitude_entered = temp;
        steps_per_amplitude = (steps_per_rev * gear_ratio * (amplitude_entered/max_amplitude))/2;
        Serial.print("Aplitude changed to ");
        Serial.print(amplitude_entered);
        Serial.println("meters");
        resetStepper(90);
        Serial.println(step_pos%1600);
        temp = stepper.speed();
        stepper.stop();
        stepper.setSpeed(temp);
        delay(2000);
        /*temp = stepper.speed();
        stepper.setCurrentPosition(1);
        delay(10);
        stepper.setSpeed(temp);
        //Serial.println(stepper.currentPosition());
        //Serial.println(stepper.speed());
        //Serial.println(steps_per_amplitude);*/
      }
      else
      {
        Serial.println("Out of bounds error 2");
      }
    }
    
    readstring="";
  }
  if(state>0)
  {
    keepRunning();
    step_pos = stepper.currentPosition() % 2500;
  }

 if(amplitude_entered<.2)
  {
    if(abs(step_pos) >= ((steps_per_amplitude/2)+(625)) || abs(step_pos) <= (625-(steps_per_amplitude/2))) //10k = full rotation/4 = 90 degrees
    {
      //Serial.println("Change");
      //Serial.println(stepper.currentPosition());
      //Serial.println(step_pos);
      reverseSpeed();
     }
  }
}

void resetStepper(int angle)
{
  switch (angle)
  {
   case 0:
    while(abs(step_pos)!=0)
         {
           keepRunning();
           step_pos = stepper.currentPosition() % 2500;
         }
         break;
         
      case 90:
      
        while(abs(step_pos)!=(625))
        {
          keepRunning();
          step_pos = stepper.currentPosition() % 2500;
        }
      break;
      default:
      while(abs(step_pos)!=0)
         {
           keepRunning();
           step_pos = stepper.currentPosition() % 2500; // 40k is 12.5*3200, now 20k = 12.5*1600 was getting a lot of issues with typecasting
         }
         break;
    }
      temp = stepper.speed();
      stepper.stop();
      delay(500);
      stepper.setSpeed(temp);
}

void reverseSpeed()
{
      temp = stepper.speed();
      stepper.stop();
      delay(1000);
      stepper.setSpeed(temp*-1);
}

void keepRunning()
{
  digitalWrite(6,HIGH);
  digitalWrite(7,LOW);
  stepper.runSpeed();
}


