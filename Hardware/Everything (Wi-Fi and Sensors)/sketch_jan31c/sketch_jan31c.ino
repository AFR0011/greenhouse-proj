// Include libraries
#include "Adafruit_Sensor.h"
#include "DHT.h"
#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert your network credentials
#define WIFI_SSID "WIFI_SSID"
#define WIFI_PASSWORD "WIFI_PASSWORD"

// Insert Firebase project API Key
#define API_KEY "AIzaSyC9Yb8SohWmWsAWxkKcj7eUcIqJnl_jdYc"

// Insert Authorized Email and Corresponding Password
#define USER_EMAIL "admin@admin.com"
#define USER_PASSWORD 123456

// Insert RTDB URLefine the RTDB URL
#define DATABASE_URL "https://wifi-arduino-test-58c55-default-rtdb.europe-west1.firebasedatabase.app/readings/temperature"

// Define Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Variable to save USER UID
String uid;

// Database main path (to be updated in setup with the user UID)
String databasePath;
// Database child nodes
String tempPath = "/temperature";
String humPath = "/humidity";
String presPath = "/pressure";
String timePath = "/timestamp";

// Parent Node (to be updated in every loop)
String parentPath;

FirebaseJson json;

// Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

// Variable to save current epoch time
int timestamp;

// Data
float soilMoisture; // Soil moisture in %
float humidity; // DHT Humidity in %
float temperature; // DHT Temperature in Degrees Celsius
int intruderDetected; // IR Beam boolean
int gas; // Gas in %
float phc; // Photocell in %

// Timer variables (send new readings every timerDelay milliseconds)
unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 180000;

// Define DHT type
#define DHTTYPE DHT22

// Define pins
#define gasPin A0 // Gas sensor
#define ledPin A1 // LED
#define phcPin 2 // photocell sensor
#define dhtPin 3 // DHT22
#define smPin A2 // Soil moisture sensor
#define irPin 5 // IR beam sensor
#define l298Ena 6 // L298 Enable 
#define smIn1 7 // Pump VCC
#define bzPin 8 // Buzzer VCC
#define smIn2 9 // Pump GND
#define dhtIn3 10 // Fan VCC
#define dhtIn4 11 // Fan GND

DHT dht = DHT(dhtPin, DHTTYPE);

// Define functions

void initWiFi() { // Initialize WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
  Serial.println();
}

unsigned long getTime() { // Get current epoch time
  timeClient.update();
  unsigned long now = timeClient.getEpochTime();
  return now;
}


// Equipment control functions 
void pumpTurnOn(float pwm){
  digitalWrite(smIn1, HIGH);
  digitalWrite(smIn2, LOW);
  analogWrite(l298Ena, pwm);
  delay(500);
}

/*CHECK FUNCTIONALITY*/
// void pumpTurnOff(float pwm) {
//   digitalWrite(smIn1, LOW);
//   digitalWrite(smIn2, HIGH);
//   analogWrite(l298Ena, pwm);
//   delay(500);
// }

void fanTurnOn(float pwm){
  digitalWrite(dhtIn3, HIGH);
  digitalWrite(dhtIn4, LOW);
  analogWrite(l298Ena, pwm);
  delay(500);
}
void buzzerTurnOn() {
  digitalWrite(bzPin, HIGH);
  Serial.println("Turning Buzzer On!");
  delay(500);
}
void buzzerTurnOff() {
  Serial.println("Turning Buzzer Off!");
  digitalWrite(bzPin, LOW);
  delay(500);
}

void soilMoistureCondition(limit, condition, soilMoisture) {
  if (condition == "lower") {
    if (soilMoisture > limit) {
      turnPumpOn();
    }
  }
}

void setup() {
  // Set pin modes
  pinMode(gasPin, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(phcPin, INPUT);
  pinMode(dhtPin, INPUT);
  pinMode(smPin, INPUT);
  pinMode(irPin, INPUT);
  pinMode(l298Ena, OUTPUT);
  pinMode(smIn1, OUTPUT);
  pinMode(smIn2, OUTPUT);
  pinMode(bzPin, OUTPUT);
  pinMode(bzPin, OUTPUT);
  pinMode(dhtIn3, OUTPUT);
  pinMode(dhtIn4, OUTPUT);

  // Initialize time and WiFi
  initWiFi();
  timeClient.begin();

  // Assign database connection parameters
  config.api_key = API_KEY
  config.database_url = DATABASE_URL
  auth.user.email = USER_EMAIL
  auth.user.password = USER_PASSWORD
  
  // More configuration
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);

  // Assign the callback function for the long running token generation task 
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  // Assign the maximum retry of token generation
  config.max_token_generation_retry = 5;

  
  // Initialize the library with the Firebase authen and config
  Firebase.begin(&config, &auth);

  // Wait for user UID (i.e. connection)
  while(auth.token.uid == "") {
    delay(1000);
  }
  uid = auth.token.uid.c_str();

  // Update database path
  databasePath = "/readings"

  // Begin DHT
  dht.begin();

  // Begin serial monitoring
  Serial.begin(9600);
}

void loop() {
  
  // Read sensor values
  soilMoisture = (abs(1023 - analogRead(smPin)) / 1023) * 100;
  humidity = dht.readHumidity();
  temperature  = dht.readTemperature();
  intruderDetected = digitalRead(irPin);
  gas = map(analogRead(gasPin), 0, 1023, 0, 255);
  phc = digitalRead(phcPin);

  // SEND DATA TO DATABASE

  // GET "CONDITIONS" AND "ACTIONS"

  // CALL FUNCTIONS BASED ON THOSE

}