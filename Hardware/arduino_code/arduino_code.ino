// Include libraries
#include "Adafruit_Sensor.h"
#include "DHT.h"
#include <ArduinoJson.h>
#include <SoftwareSerial.h>

// Variable to save current epoch time
int timestamp;

// Data
float soilMoisture;    // Soil moisture in %
float humidity;        // DHT Humidity in %
float temperature;     // DHT Temperature in Degrees Celsius
int intruderDetected;  // IR Beam boolean
int gas;               // Gas in %
float phc;             // Photocell in %

// Timer variables (send new readings every timerDelay milliseconds)
unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 10000;

// Define DHT type
#define DHTTYPE DHT22

// Define pins
#define gasPin A0      // Gas sensor
#define ledPin A1      // LED
#define phcPin 2       // photocell sensor
#define dhtPin 3       // DHT22
#define smPin A2       // Soil moisture sensor
#define irPin 5        // IR beam sensor
#define l298EnaPump 6  // L298 Enable A (for pump)
#define l298EnaFan 12  // L298 Enable B (for fan)
#define smIn1 7        // Pump VCC
#define bzPin 8        // Buzzer VCC
#define smIn2 9        // Pump GND
#define dhtIn3 10      // Fan VCC
#define dhtIn4 11      // Fan GND
DHT dht = DHT(dhtPin, DHTTYPE);

// Equipment control functions
void pumpToggle(float pwm, bool status) {
  digitalWrite(smIn1, status);
  digitalWrite(smIn2, !status);
  digitalWrite(l298EnaPump, pwm);
  // Serial.println("Toggling pump.");
  delay(500);
}

void fanToggle(float pwm, bool status) {
  digitalWrite(dhtIn3, status);
  digitalWrite(dhtIn4, !status);
  digitalWrite(l298EnaFan, pwm);
  // Serial.println("Toggling fan.");
  delay(500);
}

void buzzerToggle(bool status) {
  digitalWrite(bzPin, status);
  // Serial.println("Toggling buzzer.");
  delay(500);
}

void lightToggle(bool status) {
  if (status) {
    analogWrite(ledPin, 255);
  } else {
    analogWrite(ledPin, 0);
  }
  // Serial.println("Toggling light.");
  delay(500);
}

void setup() {
  // Set pin modes
  pinMode(gasPin, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(phcPin, INPUT);
  pinMode(dhtPin, INPUT);
  pinMode(smPin, INPUT);
  pinMode(irPin, INPUT);
  pinMode(l298EnaPump, OUTPUT);
  pinMode(l298EnaFan, OUTPUT);
  pinMode(smIn1, OUTPUT);
  pinMode(smIn2, OUTPUT);
  pinMode(bzPin, OUTPUT);
  pinMode(dhtIn3, OUTPUT);
  pinMode(dhtIn4, OUTPUT);

  // Begin DHT
  dht.begin();

  // Begin serial monitoring
  Serial.begin(115200);
}

void loop() {
  soilMoisture = (abs(1023 - analogRead(smPin)) / 1023) * 100;
  humidity = dht.readHumidity();
  temperature = dht.readTemperature();
  intruderDetected = digitalRead(irPin);
  gas = map(analogRead(gasPin), 0, 1023, 0, 255);
  phc = digitalRead(phcPin);

  // Send readings over serial
  Serial.print("{\"readings\": {\"soilMoisture\" : ");
  Serial.print(soilMoisture);
  Serial.print(", \"humidity\" : ");
  Serial.print(humidity);
  Serial.print(", \"temperature\" : ");
  Serial.print(temperature);
  Serial.print(", \"gas\" : ");
  Serial.print(gas);
  Serial.print(", \"lightIntensity\" : ");
  Serial.print(phc);
  Serial.print(", \"intruder\" : ");
  Serial.print(intruderDetected);
  Serial.println("}}");
  sendDataPrevMillis = millis();
  if (soilMoisture < 1) {
    Serial.print("PUMP ON");
    pumpToggle(255, true);
    delay(1000);
  } else {
    pumpToggle(0, false);
    delay(1000);
  }
  if (temperature < 30) {
    fanToggle(255, true);
    delay(1000);
  } else {
    fanToggle(0, false);
    delay(1000);
  }
  if (gas > 75) {
    buzzerToggle(true);
    delay(1000);
  } else {
    buzzerToggle(false);
    delay(1000);
  }
  if (intruderDetected) {
    lightToggle(true);
    delay(1000);
  } else {
  lightToggle(false);
  delay(1000);
  }
  // Check for incoming data
  if (!(Serial.available() > 0)) {
    // Get input and parse to json
    String input = Serial.readStringUntil('\n');
    StaticJsonDocument<1024> receivedJson;  // Adjust the size as needed
    DeserializationError error = deserializeJson(receivedJson, input);

    if (error) {
      // Serial.print("Failed to parse JSON: ");
      // Serial.println(error.c_str());
      return;
    }

    // Separate programs and equipment
    JsonArray programs = receivedJson["programs"].as<JsonArray>();
    JsonObject equipment = receivedJson["equipment"].as<JsonObject>();

    for (JsonObject program : programs) {
      const char* equip = program["equipment"];
      int condition = program["condition"];
      int action = program["action"];
      int limit = program["limit"];

      if (strcmp(equip, "fan") == 0) {
        if ((condition == "lt" && humidity < limit) || (condition == "gt" && humidity > limit)) {
          fanToggle(255, action == "on");
        }
      } else if (strcmp(equip, "light") == 0) {
        if ((condition == "lt" && phc < limit) || (condition == "gt" && phc > limit)) {
          lightToggle(action == "on");
        }
      } else if (strcmp(equip, "pump") == 0) {
        if ((condition == "lt" && soilMoisture < limit) || (condition == "gt" && soilMoisture > limit)) {
          pumpToggle(255, action == "on");
        }
      }
    }
  }
}
