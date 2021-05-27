//===================================
// RB 2021 1.0
// Controller for the RB kit.
//
// Autor: Felipe Arisi
// Last revision: 2021-05-21
//===================================

//===================================
// Libraries
//===================================
#include "CRServo.h"
#include "FlameSensor.h" 
#include <NewPing.h>
#include <Wire.h>
//======================================================================
// Pins
//======================================================================
#define START_BUTTON_PIN 41 
#define STOP_BUTTON_PIN 40


#define LEFT_SERVO_PIN 10
#define RIGHT_SERVO_PIN 11

#define LEFT_SONAR_PIN 42
#define FRONT_SONAR_PIN 43
#define RIGHT_SONAR_PIN 44

#define LEFT_BUMPER_PIN 38
#define RIGHT_BUMPER_PIN 39

#define RED_LED_PIN 37

#define FAN_MOTOR_PIN 34

#define LINE_SENSOR_PIN A0
//======================================================================
// Constants 
//======================================================================
const int WAIT = 0;
const int NAVIGATE = 1;
const int CENTER = 2;
const int PUT_OUT = 3;

const int MAX_SONAR_DIST = 100;
const int MAX_RIGHT_DIST = 15;
const int GAIN = 1.0;
const int BASE_POWER = 10;
const int DELTA_LIMIT = 5; // limite para o robo fazer as curvas
const int MAX_FRONT_DIST = 15; // distancia quando tem uma parade na frete (virar para esquerda)
const int ROTATE_POWER = 10;//power rotação
const float FLOOR1 = 15.5; // superficie do robô -- arena do concurso
const float FLOOR2 = 8.0; //superficie das salas do IPG
const int MAX_FLAME_DIST = 15; // distancia para realizar o center 

const int CIRCLE_TAG = 0; // Definem o tipo de superficie que o carrinho está 
const int LINE_TAG = 1;
const int NO_TAG = 2;

const int LINE_SENSOR_LIMIT 80
//======================================================================
// Objects 
//======================================================================
CRServo leftMotor(true, 30);
CRServo rightMotor(false, 30);

NewPing leftSonar(LEFT_SONAR_PIN, LEFT_SONAR_PIN, MAX_SONAR_DIST);
NewPing frontSonar(FRONT_SONAR_PIN, FRONT_SONAR_PIN, MAX_SONAR_DIST);
NewPing rightSonar(RIGHT_SONAR_PIN, RIGHT_SONAR_PIN, MAX_SONAR_DIST);


FlameSensor flameSensor(3);



//======================================================================
// Variables 
//======================================================================
int state;

int flameDir;
int flameX;
int flameY;

int room;
bool flameInRoom;
int tag;
//======================================================================
// Setup 
//======================================================================
void setup() {
  Serial.begin(9600);
  state = WAIT;
  
  // ======= Object Configuration =====
  leftMotor.attach(LEFT_SERVO_PIN);
  rightMotor.attach(RIGHT_SERVO_PIN);

  Wire.begin();
  flameSensor.begin();
 
  // ======= Pin Configuration =====
  pinMode(START_BUTTON_PIN, INPUT_PULLUP);
  pinMode(STOP_BUTTON_PIN, INPUT_PULLUP);

  pinMode(LEFT_SERVO_PIN, OUTPUT);
  pinMode(RIGHT_SERVO_PIN, OUTPUT);

  pinMode(LEFT_BUMPER_PIN, INPUT_PULLUP);
  pinMode(RIGHT_BUMPER_PIN, INPUT_PULLUP);

  pinMode(RED_LED_PIN, OUTPUT);

  pinMode(FAN_MOTOR_PIN, OUTPUT);
  digitalWrite(FAN_MOTOR_PIN, HIGH); // low liga -- high desliga
  
}


//======================================================================
// Loop (implements the Finite State Machine) 
//======================================================================
void loop() {
  // put your main code here, to run repeatedly:
  switch(state){
    case WAIT:
      waitState();
      break;
    case NAVIGATE:
      navigateState();
      break;
    case CENTER:
      centerState();
      break;
    case PUT_OUT:
      putOutState();
      break;
  }

  if(digitalRead(STOP_BUTTON_PIN) == LOW){
    state = WAIT;
  }
  Serial.println(getStateName(state));
}

//======================================================================
// Behaviour functions  
//======================================================================

void waitState(){
    stop();
    do{
      //Serial.println("Dist: "+String(getDistance(rightSonar)));
      //Serial.println(state);
      //flameSensorTest();
      //Serial.println(analogRead(LINE_SENSOR_PIN));

      room = 0;
    }while(digitalRead(START_BUTTON_PIN) == HIGH);

    maneuverToExitWhiteCircle();
    state = NAVIGATE;
}

void navigateState(){
  // ============== 1º Action of the state ==============
  //condição caso tenha um obstaculo a frente e o robo precise virar a esquerda 
  if(getDistance(frontSonar) < MAX_FRONT_DIST ){
    //virar a esquerda 
    rotateAngle(90, FLOOR2);
  }

  if(digitalRead(LEFT_BUMPER_PIN) == LOW){
     move(-BASE_POWER, -4, 1000);
  }else if(digitalRead(RIGHT_BUMPER_PIN == LOW)){
    move(-BASE_POWER, 4, 1000);
  }
  
  // condição para ele se mandar seguindo a parede da diretia 
  int dist = getDistance(rightSonar);
  int error = MAX_RIGHT_DIST - dist;
  int delta = GAIN * error;
  delta = delta > DELTA_LIMIT ? DELTA_LIMIT : delta; // Limite para o PID para não ter uma variação muito grande
  move(BASE_POWER, delta);

  // ============== 2º Transitions conditions ==============
  flameSensor.update(flameDir, flameX, flameY);
  if(flameDir != 0){
    state = CENTER;
    return;
  }
  if(getFloorTag()==CIRCLE_TAG){
    state=WAIT;
  } 
}


void navigateStateV2(){
  // ============== 1º Action of the state ==============
  //condição caso tenha um obstaculo a frente e o robo precise virar a esquerda 
  if(getDistance(frontSonar) < MAX_FRONT_DIST ){
    //virar a esquerda 
    rotateAngle(90, FLOOR2);
  }

  if(digitalRead(LEFT_BUMPER_PIN) == LOW){
     move(-BASE_POWER, -4, 1000);
  }else if(digitalRead(RIGHT_BUMPER_PIN == LOW)){
    move(-BASE_POWER, 4, 1000);
  }
  
  // condição para ele se mandar seguindo a parede da diretia 
  int dist = getDistance(rightSonar);
  int error = MAX_RIGHT_DIST - dist;
  int delta = GAIN * error;
  delta = delta > DELTA_LIMIT ? DELTA_LIMIT : delta; // Limite para o PID para não ter uma variação muito grande
  move(BASE_POWER, delta);

  
  tag = getFloorTag();
  if(tag == CIRCLE_TAG){
    manevuerToGoToIslandRoom();
  }else if(tag == LINE_TAG){
    room++;
    stop();
    delay(1000);
    flameSensor.update(flameDir, flameX, flameY);
    if(flameDir != 0){
      flameInRoom = true;
    }else{
      maneuverToGoToNextRoom();
    }
  }
  
  
  // ============== 2º Transitions conditions ==============
  if(flameInRoom == true){
    flameSensor.update(flameDir, flameX, flameY);
    if(flameDir != 0){
      state = CENTER;
      return;
    }
  } 
}


void centerState(){
  setLED(true);
  flameSensor.update(flameDir, flameX, flameY);
  switch(flameDir){
    case 0:
      //
      state = NAVIGATE;
      setLED(false);
      return;
      break;
    case 1:
      rotate(-5);
      break;
    case 2:
      move(BASE_POWER, 0);
      if(getDistance(frontSonar) < MAX_FLAME_DIST){
        stop();
        state = PUT_OUT;
        return;
      }
      break;
    case 3:
      rotate(5);
      break;
  }

}
void putOutState(){

  digitalWrite(FAN_MOTOR_PIN, LOW);
  delay(3000);
  
  digitalWrite(FAN_MOTOR_PIN, HIGH);

  move(-BASE_POWER, 0, 1000);

  flameSensor.update(flameDir, flameX, flameY);
  if(flameDir != 0){
    state = CENTER;
    return;
  }
  
  state = WAIT;
}

//======================================================================
// Actuator functions
//======================================================================
void stop(){
  leftMotor.stop();
  rightMotor.stop();
}

void rotate(int power){
  // power + -> esquerda
  // power - -> direita
  leftMotor.setPower(-power);
  rightMotor.setPower(power);
}

void rotate(int power, int ms){
  // power + -> esquerda
  // power - -> direita
  leftMotor.setPower(-power);
  rightMotor.setPower(power);
  delay(ms);
  stop();
}

void rotateAngle(int angle, float floor){
  // if angle >= rotate left
  // if angle < rotate right
  if(angle >= 0){
      rotate(ROTATE_POWER, angle * floor);
  }else{
    rotate(-ROTATE_POWER, -angle * floor);
  }
  // 108º -----> time
  // angle ----> x = angle * (time / 1LINE_SENSOR_LIMIT)
}

void moveForward(int power, int ms){
  leftMotor.setPower(power);
  rightMotor.setPower(power);
  stop();
  delay(ms);
}

void moveForward(int power){
  leftMotor.setPower(power);
  rightMotor.setPower(power);
}

void move(int power, int delta){
  leftMotor.setPower(power - delta);
  rightMotor.setPower(power + delta);
}

void move(int power, int delta, int ms){
  leftMotor.setPower(power - delta);
  rightMotor.setPower(power + delta);
  delay(ms);
  stop();
}


void maneuverToExitWhiteCircle(){
  move(BASE_POWER, 0);
  while(analogRead(LINE_SENSOR_PIN) < LINE_SENSOR_LIMIT);
}


void maneuverToGoToIslandRoom(){
  rotateAngle(180, FLOOR2);
  move(BASE_POWER, 0, 2000);
}

void maneuverToGoToNextRoom(){
  switch(room){
    case 1:
      rotateAngle(180, FLOOR2);
      do{
        move(BASE_POWER, 0);
      }while(getDistance(fronSonar) > 15);
      break;  
    case 2:
      rotateAngle(180, FLOOR2);
      move(BASE_POWER, 3, 1000);
      break;
    case 3:
      //
      break;
  }
}

//======================================================================
// Sensor functions
//======================================================================

int getDistance(NewPing & sonar){
   int dist = sonar.ping_cm();  
   //if(dist == 0) dist = MAX_SONAR_DIST;
   dist = dist == 0 ? MAX_SONAR_DIST : dist;
   return dist;
}

void flameSensorTest(){
  int d, x, y;

  flameSensor.update(d, x, y);

  Serial.print("d: ");
  Serial.print(d);
  Serial.print("\t");
  Serial.print("x: ");
  Serial.print(x);
  Serial.print("\t");
  Serial.print("y: ");
  Serial.println(y);
}

int getFloorTag(){
  if(analogRead(LINE_SENSOR_PIN) < LINE_SENSOR_LIMIT){
     move(BASE_POWER, 0, 1000);
     if(analogRead(LINE_SENSOR_PIN) < LINE_SENSOR_LIMIT)}{
      return CIRCLE_TAG{
     }
     return LINE_TAG;
  }
  return NO_TAG;
}
//======================================================================
// Interface functions
//======================================================================
void setLED(bool s){
  if (s){
    digitalWrite(RED_LED_PIN, HIGH);
  }else{
    digitalWrite(RED_LED_PIN, LOW);
  }
}

//======================================================================
// Utility functions
//======================================================================

String getStateName(int i){
  String s = " ";
  switch(i){
    case WAIT:
      s = "WAIT";
      break;
    case NAVIGATE:
      s = "NAVIGATE";
      break;
    case CENTER:
      s = "CENTER";
      break;
    case PUT_OUT:
      s = "PUT_OUT";
      break;
  }
  return s;
}
