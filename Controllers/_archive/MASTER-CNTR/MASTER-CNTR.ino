
 #include "SoftwareSerial.h"

 const int Rx = 3; // this is physical pin 2
 const int Tx = 4; // this is physical pin 3
 SoftwareSerial mySerial(Rx, Tx);

 // sensor variables
 int analogInPin = A1; // physical pin 7
 int buttonPin = 1; // physical pin 6

void setup() {
  pinMode(Rx,INPUT);
  pinMode(Tx, OUTPUT);
  
  mySerial.begin(9600);

  establishContact();
}

void loop() {

  if (mySerial.available() > 0) {
    char c = mySerial.read();
    
    if (c == 'a') {
      //send name
      mySerial.println("hello,master");
    }

    if (c == 'k') {
      int sensorValue = analogRead(analogInPin);
      int buttonRead = digitalRead(buttonPin);

      mySerial.print(sensorValue);
      mySerial.print(",");
      mySerial.println(buttonRead);
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

