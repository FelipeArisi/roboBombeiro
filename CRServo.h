
#ifndef CRSERVO_H
#define CRSERVO_H

 #include <Arduino.h>
 #include <Servo.h>

 
 class CRServo {
   static const int MAX_FORWARD = 16;
   static const int MAX_REVERSE = -16;

   private:
     Servo mServo;
     bool mReverse;
     int mRange;

   public:
     CRServo(bool reverse, int range);
     void attach(int pin);
     void setPower(int power);
     void stop();  
   };

#endif





/*
CRServo2
  #include "CRServo.h"
    CRSERVO_H
    int a;

Control
  #include "CRServo.h"
    int a;
*/    







  