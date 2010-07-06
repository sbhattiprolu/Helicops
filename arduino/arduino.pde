#include <Wire.h>
#include <string.h>
#include <stdio.h>
#include <Servo.h>
#define ROLL 0x01
#define PITCH 0x02
#define MAIN_ENGINE 0x03
#define TAIL_ENGINE 0x04
#define SHUTDOWN 0x09
#define STARTUP 0x08
#define DEBUG 1

uint8_t outbuf[6]; // array to store arduino output
uint8_t init_sequence[6]; //array to store initialization sequence
uint8_t recbuf[10]; // array to store received commands
int cnt = 0; //counter to handle incoming data
int counter=0; //to differentiate between initialization sequence and data sent to PC
Servo roll_servo;
Servo pitch_servo;
int rollPin=9;
int pitchPin=10;
int tailPin=11;
int mainPin=5;

int rollAngle=90;
int pitchAngle=90;
int mainPower=0;
int tailPower=0;

int p_rollAngle=90;
int p_pitchAngle=90;
int p_mainPower=0;
int p_tailPower=0;



void
receiveEvent (int howMany)
{
  cnt=0;
  while (Wire.available ())
  {
    recbuf[cnt] = Wire.receive (); // receive byte as an integer
    cnt++;
  }
  //Serial.println
  //Serial.println(cnt);

  if(recbuf[1]==ROLL){
    if((recbuf[2]>49 && recbuf[2]<128) || (recbuf[2]>-4 && recbuf[1]<0)){
    recbuf[2]=recbuf[2]<=-1?recbuf[2]+131:recbuf[2];
    rollAngle=recbuf[2];
    }
    if(recbuf[3]==PITCH){
      if((recbuf[4]>49 && recbuf[4]<128) || (recbuf[4]>-4 && recbuf[4]<0)){
      recbuf[4]=recbuf[4]<=-1?recbuf[4]+131:recbuf[4];
      pitchAngle=recbuf[4];
      }
    }
    if(recbuf[5]==MAIN_ENGINE){
      if(recbuf[6]>0 && recbuf[6]<=255){
       // Serial.print("main engine");
       // Serial.print(recbuf[6],DEC);
        mainPower=recbuf[6];
        tailPower=recbuf[6];
      }
    }
    if(recbuf[7]==TAIL_ENGINE){
     if(recbuf[8]>0 && recbuf[8]<=255){
     }
    }
  }
  if(recbuf[1]==SHUTDOWN)
  {
    Serial.print("Shutdown");
    Serial.print("\n");
    rollAngle=90;
    pitchAngle=90;
    mainPower=0;
    tailPower=0;
  }
  if(recbuf[1]==STARTUP){
     Serial.print("Startup");
     Serial.print("\n");
    rollAngle=90;
    pitchAngle=90;
    mainPower=127;
    tailPower=127;
  }
}

void
requestEvent ()
{
  Serial.print(".");
  if(counter==0){
    init_sequence[0]=00;
    init_sequence[1]=00;
    init_sequence[2]=0xA4;
    init_sequence[3]=0x20;
    init_sequence[4]=00;
    init_sequence[5]=00;
    Wire.send(init_sequence,6);
    counter++;
  }
  // Send some data back to the wiimote to be transmitted back to PC
  else{
    outbuf[0] = nunchuk_encode_byte(126); // joystick X
    outbuf[1] = nunchuk_encode_byte(124); // joystick Y
    outbuf[2] = nunchuk_encode_byte(100); // Axis X
    outbuf[3] = nunchuk_encode_byte(100); // Axis Y
    outbuf[4] = nunchuk_encode_byte(100); // Axis Z
    outbuf[5] = nunchuk_encode_byte(1); // Press C button, by te[5] is buttons 
    //C,Z and accelaration data
    //outbuf[5] = nunchuk_encode_byte(2); // Press Z button
    //outbuf[5] = nunchuk_encode_byte(0); // Press Z and C button
    Wire.send (outbuf, 6); // send data packet
  }
}
void
setup ()
{
  Serial.begin (9600);
  Serial.print ("Finished setup\n");
  Wire.begin (0x52); // join i2c bus with address 0x52
  roll_servo.attach(rollPin);
  roll_servo.write(90);
  pitch_servo.attach(pitchPin);
  pitch_servo.write(90);
  Wire.onReceive (receiveEvent); // register event
  Wire.onRequest (requestEvent); // register event
}

void
loop ()
{
  if(p_rollAngle!=rollAngle){
    p_rollAngle=rollAngle;
    roll_servo.write(rollAngle);
    if(DEBUG){
      Serial.print("Roll=");
      Serial.println(rollAngle,DEC);
    }
  }
  if(p_pitchAngle!=pitchAngle){
    p_pitchAngle=pitchAngle;
    pitch_servo.write(pitchAngle);
    if(DEBUG){
      Serial.print("Pitch=");
      Serial.println(pitchAngle,DEC);
    }
    
  }
  
  if(p_mainPower!=mainPower){
    p_mainPower=mainPower;
    analogWrite(mainPin,mainPower);
    if(DEBUG){
      Serial.print("Main=");
      Serial.println(mainPower,DEC);
    }
  }
  
  if(p_tailPower!=tailPower){
    p_tailPower=tailPower;
    analogWrite(tailPin,tailPower);
    if(DEBUG){      
      Serial.print("Tail=");
      Serial.println(tailPower,DEC);
    }    
  }
  
}

// Encode data to format that most wiimote drivers except
// only needed if you use one of the regular wiimote drivers
char
nunchuk_encode_byte (char x)
{
  x = x - 0x17;
  x = (x ^ 0x17);
  return x;
}
