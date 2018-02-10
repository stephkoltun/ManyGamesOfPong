#include <ESP8266WiFi.h>

// connection switch for indicating whether this controller should be used
int switchPin = 14;
int switchState;
int LEDPin = 4;

// sensor

// name for identifying self
const char* myName = "hellocontrollerA";

// network name and password


// Use WiFiClient class in arduino library
WiFiClient client; // creates client side TCP connection
IPAddress server(128, 122, 6, 143); // IP address of server (when on iPhone)
// This is pulled from the Processing sketch
const int httpPort = 12345;       // Port is also determined in the Processing sketch


void setup() {
#ifndef ESP8266
  while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
#endif

  pinMode(switchPin, INPUT);
  pinMode(LEDPin, OUTPUT);

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

  if (switchState == HIGH && (client.connected() == false)) {
    // try to connect and blink light
    Serial.println("try to connect");

    if (client.connect(server, httpPort)) {
      Serial.println("connect");
      Serial.println("say hello and provide feedback");
      client.write(myName);
      digitalWrite(LEDPin, HIGH);
    } else {
      Serial.println("connection failed");
      digitalWrite(LEDPin, HIGH);
      delay(200);
      digitalWrite(LEDPin, LOW);
      delay(200);
      digitalWrite(LEDPin, HIGH);
      delay(200);
      digitalWrite(LEDPin, LOW);
      delay(200);
    }
  }

  else if (switchState == HIGH && client.connected()) {
    // read sensors

  }

  else if (switchState == LOW && client.connected()) {
    // disconnect from gamge
    Serial.println("disconnect from game");
    client.write('remove');
    client.stop();
    digitalWrite(LEDPin, LOW);
  }

}
