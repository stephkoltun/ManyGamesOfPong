#include <ESP8266WiFi.h>

// connection switch for indicating whether this controller should be used
int switchPin = 14;
int switchState;
int LEDPin = 4;
int errorPin = 5;
int prevSpeed;

// sensor
int upPin = 12; // switch for up
int dnPin = 13; // switch for dn
int prevUp = LOW;
int prevDn = LOW;

// name for identifying self
const char* myName = "hellocontrollerA";

// Wifi Configuration


// Use WiFiClient class in arduino library
WiFiClient client; // creates client side TCP connection
//IPAddress server(192,168,1,3); // IP address of server
//IPAddress server(172,20,10,3); 
IPAddress server(192,168,1,6);
const int httpPort = 12345;       // Port is also determined in the Processing sketch
int connectAttempts = 0;


void setup() {
#ifndef ESP8266
  while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
#endif

  pinMode(switchPin, INPUT);
  pinMode(LEDPin, OUTPUT);
  pinMode(errorPin, OUTPUT);
  pinMode(A0, INPUT);

  Serial.begin(115200);


  // All controllers will start by connecting to the WiFi network
  // We start by connecting to a WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(800);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi successfully connected!");
  Serial.println("Client IP address: ");
  Serial.println(WiFi.localIP());

}

void loop() {
  delay(10);

  // read switch to determine whether to send data or not
  switchState = digitalRead(switchPin);

  Serial.println(digitalRead(dnPin));

  if (switchState == HIGH && (client.connected() == false)) {
    // try to connect and blink light
    Serial.println("try to connect");
    digitalWrite(LEDPin, HIGH);
    delay(200);
    digitalWrite(LEDPin, LOW);
    delay(200);
    digitalWrite(LEDPin, HIGH);
    delay(200);
    digitalWrite(LEDPin, LOW);
    delay(200);

    if (client.connect(server, httpPort) && (connectAttempts < 3)) {
      Serial.println("connect");
      Serial.println("say hello and provide feedback");
      client.write(myName);
      digitalWrite(LEDPin, HIGH);
      digitalWrite(errorPin, LOW);
    } else {
      if (connectAttempts < 3) {
        connectAttempts++;
        Serial.println("connection " + String(connectAttempts) + " failed");
        digitalWrite(LEDPin, HIGH);
        delay(200);
        digitalWrite(LEDPin, LOW);
        delay(200);
        digitalWrite(LEDPin, HIGH);
        delay(200);
        digitalWrite(LEDPin, LOW);
        delay(200);
      } else {
        Serial.println("couldn't connect after 3 tries, reset");
        digitalWrite(LEDPin, LOW);
        digitalWrite(errorPin, HIGH);
        connectAttempts = 0;
        delay(1000);
      }
    }
  }

  else if (switchState == HIGH && client.connected()) {

    // read pot for speed adjustments
    int potValue = analogRead(A0);
    int speedIncrement = map(potValue, 4, 880, 2, 10);
    if (speedIncrement != prevSpeed) {
      String speedMessage = "s" + String(speedIncrement);
      Serial.print("new speed: ");
      Serial.println(speedIncrement);
      client.print(speedMessage);
    }
    prevSpeed = speedIncrement;


    // read sensors
    int upState = digitalRead(upPin);
    int dnState = digitalRead(dnPin);

    if (upState == HIGH && (prevUp != HIGH)) {
      Serial.println("u");
      client.write('u');
    }

    if (dnState == HIGH && (prevDn != HIGH)) {
      client.write('d');
      Serial.println("d");
    }

    if ((dnState == LOW && upState == LOW) && (prevDn != LOW || prevUp != LOW)) {
      client.write("reset");
      Serial.println("stop moving");
    }
    prevUp = upState;
    prevDn = dnState;
  }

  else if (switchState == LOW && client.connected()) {
    // disconnect from gamge
    Serial.println("disconnect from game");
    client.write("remove");
    digitalWrite(LEDPin, LOW);
  }

  else if (switchState == LOW && client.connected() == false) {
    digitalWrite(LEDPin, LOW);
    digitalWrite(errorPin, LOW);
  }

}
