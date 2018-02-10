#include <ESP8266WiFi.h>

// connection switch for indicating whether this controller should be used
int switchPin = 14;
int switchState;
int LEDPin = 4;
int errorPin = 5;
int prevSpeed;

// sensor
int upPin = 13; // button for up
int dnPin = 12; // button for dn
int prevUp = LOW;
int prevDn = LOW;

// message threshold
int sendInterval = 100;
long lastTimeSent = 0;

// name for identifying self
const char* myName = "hellocontrollerB";

// Wifi Configuration


// Use WiFiClient class in arduino library
WiFiClient client; // creates client side TCP connection
//IPAddress server(192, 168, 1, 3); // home
//IPAddress server(128, 122, 6, 189); // itp
//IPAddress server(172,20,10,3);
IPAddress server(192,168,1,7);
// This is pulled from the Processing sketch
const int httpPort = 12345;       // Port is also determined in the Processing sketch
int connectAttempts = 0;


void setup() {
#ifndef ESP8266
  while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
#endif

  pinMode(upPin, INPUT);
  pinMode(dnPin, INPUT);
  pinMode(LEDPin, OUTPUT);
  pinMode(errorPin, OUTPUT);

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
  long now = millis();

  // read switch to determine whether to send data or not
  switchState = digitalRead(switchPin);

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

    // read sensors
    int upState = digitalRead(upPin);
    int dnState = digitalRead(dnPin);

    if (upState == HIGH && (prevUp != HIGH)) {
      if (now - lastTimeSent > sendInterval) {
        Serial.println("u");
        client.write('u');
        lastTimeSent = now;
      }
    }

    if (dnState == HIGH && (prevDn != HIGH)) {
      if (now - lastTimeSent > sendInterval) {
        Serial.println("d");
        client.write('d');
        lastTimeSent = now;
      }
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
