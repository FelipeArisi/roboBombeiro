#include "FlameSensor.h" 
#include <Wire.h>

FlameSensor::FlameSensor(int divisions){
  divisions = divisions < 1 ? 1 : divisions;
  divisions = divisions > 5 ? 5 : divisions;

  mDivLength = 1024 / divisions; 
  
}

void FlameSensor::update(int &flameDirection, int &flameX, int &flameY){
  Wire.beginTransmission(ADDRESS);
  Wire.write(0x36);
  Wire.endTransmission();

  Wire.requestFrom(ADDRESS, 4);

  int i;
  for(i=0;i<4;i++)
    mBuffer[i] = 0;

  i = 0;

  while(Wire.available() && i < 4){
    mBuffer[i++] = Wire.read();
  }

  flameX = mBuffer[1];
  flameY = mBuffer[2];
  int s = mBuffer[3];

  flameX = flameX + (s & 0x30) << 4; // s4 s5 x6 x5 x4 x3 x2 x1 x0 y0
  flameY = flameY + (s & 0xC0) << 2; // s7 s6 y7 y6 y5 y4 y3 y2 y1 y0

  
  flameDirection = flameX < 1023 ? flameX / mDivLength + 1 : 0;
}


void FlameSensor::begin(){
    Write_2bytes(0x30,0x01); delay(10);
    Write_2bytes(0x30,0x08); delay(10);
    
    Write_2bytes(0x06,0x90); delay(10);
    Write_2bytes(0x08,0xC0); delay(10);
    Write_2bytes(0x1A,0x40); delay(10);
    
    Write_2bytes(0x33,0x33); delay(10);
    delay(100); 
}


void FlameSensor::Write_2bytes(byte d1, byte d2)
{
    Wire.beginTransmission(ADDRESS);
    Wire.write(d1); Wire.write(d2);
    Wire.endTransmission();
}
