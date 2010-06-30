#include <Wire.h>
#include <Servo.h>
#include <string.h>
#include <stdio.h>
#define KEY_UP 0x01
#define KEY_DOWN 0x02
#define KEY_LEFT 0x03
#define KEY_RIGHT 0x04

uint8_t outbuf[6]; // array to store arduino output
uint8_t recbuf[10];
int cnt = 0;
Servo servox;
int servo_value=90;
int p_servo_value=90;


//Detect the Key Pressed
void
DetectKey()
{
  switch(recbuf[1])
  {
    case KEY_UP:
      Serial.println("UP");
      if(servo_value<=145)
        servo_value+=5;
      break;
    case KEY_DOWN:
      Serial.println("DOWN");
      if(servo_value>=45)
        servo_value-=5;
      break;
    case KEY_LEFT:
      Serial.println("LEFT");
      break;
    case KEY_RIGHT:
      Serial.println("RIGHT");
      break;
    default:
      Serial.print("Unknown Key ");
      Serial.println(recbuf[1],DEC);
      break;
  }
}

void
receiveEvent (int howMany)
{
  //Serial.println("Recieve Event");
  cnt=0;
  while (Wire.available ())
  {
      recbuf[cnt] = Wire.receive ();	// receive byte as an integer
      cnt++;
  }
  if(recbuf[0]==1)
    DetectKey();

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

void
requestEvent ()
{
  Serial.print(".");
  // Send some data back to the wiimote to be transmitted back to PC
  outbuf[0] = nunchuk_encode_byte (125+cnt);	// joystick X
  outbuf[1] = nunchuk_encode_byte (126);	// joystick Y
  outbuf[2] = nunchuk_encode_byte (227);	// Axis X
  outbuf[3] = nunchuk_encode_byte (241);	// Axis Y
  outbuf[4] = nunchuk_encode_byte (140);	// Axis Z
  outbuf[5] = nunchuk_encode_byte (1);	// Press C button, byte[5] is buttons 
  //C,Z and accelaration data
  //outbuf[5] = nunchuk_encode_byte(2); // Press Z button
  //outbuf[5] = nunchuk_encode_byte(0); // Press Z and C button
  Wire.send (outbuf, 6);	// send data packet
}

void
setup ()
{
  Serial.begin (9600);
  Serial.print ("Finished setup\n");
  Wire.begin (0x52);		// join i2c bus with address 0x52
  Wire.onReceive (receiveEvent);	// register event
  Wire.onRequest (requestEvent);	// register event
  servox.attach(5);
  servox.write(servo_value);
  
}

void
loop ()
{
  if(p_servo_value!=servo_value)
  {
    p_servo_value=servo_value;
    servox.write(servo_value);
  }
}

