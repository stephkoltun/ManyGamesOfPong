#include "SoftwareSerial.h"

const int Rx = 3; // this is physical pin 2
const int Tx = 4; // this is physical pin 3
SoftwareSerial mySerial(Rx, Tx);


// button variables
const int upPin = 2; // physical pin 7
const int dnPin = 1; // physical pin 6

// SETUP
void setup() {
  pinMode(Rx, INPUT);
  pinMode(Tx, OUTPUT);

  // initialize serial communication at 9600 bits per second:
  mySerial.begin(9600);

  establishContact();
}

// the loop function runs over and over again forever
void loop() {
  
  if (mySerial.available() > 0) {
    char c = mySerial.read();

    

    if (c == 'a') {
      //send name
      mySerial.println("hello,controllerB");
    }

    if (c == 'k') {
      int upRead = digitalRead(upPin);
      int dnRead = digitalRead(dnPin);
      mySerial.print(upRead);
      mySerial.print(",");
      mySerial.println(dnRead);
    } 
    delay(10);
  }
}


void establishContact() {
  while (mySerial.available() <= 0) {
    mySerial.println("plugged");
    delay(100);
  }
}

