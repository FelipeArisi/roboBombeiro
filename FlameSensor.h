
#ifndef FLAME_SENSOR_H
#define FLAME_SENSOR_H

#include <Arduino.h>

#define ADDRESS 0x58

class FlameSensor {
  private:
    int mDivLength;
    byte mBuffer[4];
    void Write_2bytes(byte d1, byte d2);
    
  public: 
    FlameSensor(int divisions);
    void begin();
    void update(int &flameDirectin, int &flameX, int &flameY);
};

#endif
