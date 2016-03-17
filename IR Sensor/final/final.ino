#include "TimerOne.h"
#include <SharpIR.h> 

SharpIR sharp(A0, 25, 93, 20150);
unsigned long time;
void setup()
{
  Serial.begin(9600);
  Timer1.initialize(10000);    //note to rushat: 500000 gives a value every 0.5 seconds ; 1000000 gives a value every 1 second;
}
 
void callback()
{
   int dis=sharp.distance();
  dis= ((dis+5.5287)/1.1864);
  Serial.println(dis);
}
 
void loop()
{
 Timer1.attachInterrupt(callback);  // attaches callback() as a timer overflow interrupt
}
