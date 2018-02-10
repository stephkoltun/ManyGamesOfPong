

/*
    Simple HTTP get webclient test
    Source: https://learn.adafruit.com/adafruit-feather-huzzah-esp8266/using-arduino-ide
*/

#include <ESP8266WiFi.h>
// connection switch for indicating whether this controller should be used
int switchPin = 16;
int switchState = LOW;
int prevSwitchState = LOW;
int LEDPin = 2;
// pole 3 of the switch is connected to power
// pole 1 is connected to an indicator LED
// pole 5 is connected to pin 2
// if pin 16 reads HIGH, consider the controller as "OFF"

// variables for tracking sensor input
int upButtonPin = 14;
int upButtonState;
int upPrevButtonState = LOW;
int dnButtonPin = 12;
int dnButtonState;
int dnPrevButtonState = LOW;



// name for identifying self
const char* myName = "hellocontrollerB";

// network name and password
// change to ITP sandbox
const char* ssid     = "Stephanie's iPhone";
const char* password = "uxvnnfwfqhah0";

// Use WiFiClient class in arduino library
WiFiClient client; // creates client side TCP connection
IPAddress server(172, 20, 10, 3); // IP address of server (when on iPhone)
//IPAddress server(172, 20, 10, 5); // PB's phone
// This is pulled from the Processing sketch
const int httpPort = 12345;       // Port is also determined in the Processing sketch


void setup() {
  Serial.begin(115200);
  delay(100);

  pinMode(upButtonPin, INPUT);
  pinMode(dnButtonPin, INPUT);
  pinMode(switchPin, INPUT);
  pinMode(LEDPin, OUTPUT);

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
  // Huzzah IP 172.20.10.6
}

void loop() {
  delay(50);

  // read switch to determine whether to send data or not
  switchState = digitalRead(switchPin);
  Serial.println(switchState);

  if (switchState == 1) {
    digitalWrite(LEDPin, HIGH);
  } else {
    digitalWrite(LEDPin, LOW);
  }

  // if the switch is in the "ON" position
  // button should be read, so that it can send data, but only if pressed
  // HIGH == controller is OFF, HIGH == controller is ON and being used by player

  if (client.connected() == false) {

    if (switchState != prevSwitchState) {
      // if went from high to LOW, controller was turned ON
      if (switchState == LOW) {
        // open connection
        if (client.connect(server, httpPort)) {
          Serial.println("connected");
          Serial.println("say hello");
          client.write(myName);
        } else {
          Serial.println("connection failed");
        }
      }
    }

  } else {    // client is already connected

    // if went from LOW to HIGH, controller was turned off
    // so send message to remove from list
    // and close connection
    if (switchState != prevSwitchState) {
      if (switchState == HIGH) {
        Serial.println("say goodbye");
        // tell game to remove its ID from active list
        client.write("remove");
        client.stop();
      }
    }

    if (switchState == LOW) {
      // read the buttons
      upButtonState = digitalRead(upButtonPin);
      dnButtonState = digitalRead(dnButtonPin);

      // compare to prev state...
      // make sure the button was released so player can't hold it down!
      if (upButtonState != upPrevButtonState) {
        if (upButtonState == HIGH) {
          Serial.println("send message");
          // send data to game
          client.write("u");
        }
      }

      if (dnButtonState != dnPrevButtonState) {
        if (dnButtonState == HIGH) {
          Serial.println("send message");
          // send data to game
          client.write("d");
        }
      }
    }
  }
  // save for next loop
  prevSwitchState = switchState;
  upPrevButtonState = upButtonState;
  dnPrevButtonState = dnButtonState;
}
