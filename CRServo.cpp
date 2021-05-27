
#include "CRServo.h"

CRServo::CRServo(bool reverse, int range) {
  mReverse = reverse;
  mRange = range;
}

void CRServo::attach(int pin) {
  mServo.attach(pin);
}


void CRServo::setPower(int power) {
  if(mReverse == true)
    power = -power;

  if(power > MAX_FORWARD)
    power = MAX_FORWARD;
  else if(power < MAX_REVERSE)
    power = MAX_REVERSE;

  //[90-mRange, 90+mRange] --> [90-12, 90+12] or [90-30, 90+30] 
  //[-mRange, mRange]
  //MAX_FORWARD ---> mRange
  //power ----> x = power * mRange / MAX_FORWARD
  
  mServo.write((power* mRange) / MAX_FORWARD + 90);
}


void CRServo::stop() {
  mServo.write(90);
}