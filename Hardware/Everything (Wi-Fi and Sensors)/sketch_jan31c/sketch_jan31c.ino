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
#define USER_PASSWORD 12345678

// Insert RTDB URLefine the RTDB URL
#define DATABASE_URL "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app/"

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
String intrPath = "/intruder";
String phcPath = "/light";
String gasPath = "/gas";
String smPath = "/soilMoisture";
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
void pumpToggle(float pwm, int status){
  digitalWrite(smIn1, status);
  digitalWrite(smIn2, !status);
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
  if (condition == 1) {
    if (soilMoisture < limit) {
      action
    }
  }
}


if (soilMositure ">50")

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
  databasePath = getTime() + "/";

  // Begin DHT
  dht.begin();

  // Begin serial monitoring
  Serial.begin(9600);
}

class Program {       
  public:
  int action;
  int limit;
  string equipment;
  int condition;
};

void loop() {
  
  // Read sensor values
  soilMoisture = (abs(1023 - analogRead(smPin)) / 1023) * 100;
  humidity = dht.readHumidity();
  temperature  = dht.readTemperature();
  intruderDetected = digitalRead(irPin);
  gas = map(analogRead(gasPin), 0, 1023, 0, 255);
  phc = digitalRead(phcPin);

  // SEND DATA TO DATABASE

  // Prepare JSON data
  json.clear();
  json.addFloat("soilMoisture", soilMoisture);
  json.addFloat("humidity", humidity);
  json.addFloat("temperature", temperature);
  json.addInt("intruderDetected", intruderDetected);
  json.addInt("gas", gas);
  json.addFloat("light", phc);

  // Get current epoch time
  timestamp = getTime();

  // Define parent path
  parentPath = databasePath + boardNo + "/readings";
  // 12345678/1/readings

  // Set child paths
  String tempDataPath = parentPath + tempPath; // 12345678/1/readings/temperature
  String humDataPath = parentPath + humPath; 
  String intrDataPath = parentPath + intrPath;
  String gasDataPath = parentPath + gasPath;
  String phcDataPath = parentPath + phcPath;
  String smDataPath = parentPath + smPath;
  String timeDataPath = parentPath + timePath;
  

  // Push data to Firebase
  Firebase.setFloat(fbdo, tempDataPath, json.getFloat("temperature"));
  Firebase.setFloat(fbdo, humDataPath, json.getFloat("humidity"));
  Firebase.setInt(fbdo, presDataPath, json.getInt("intruder"));
  Firebase.setFloat(fbdo, presDataPath, json.getFloat("soilMoisture"));
  Firebase.setFloat(fbdo, presDataPath, json.getFloat("light"));
  Firebase.setInt(fbdo, presDataPath, json.getInt("gas"));
  Firebase.setInt(fbdo, timeDataPath, timestamp);


 /* // Handle errors, if any
  if (Firebase.failed()) {
    Serial.print("Error sending data to Firebase: ");
    Serial.println(Firebase.error());
  } else {
    // SEND API REQUEST

    Serial.println("Data sent to Firebase successfully!");
  }
*/if (!Firebase.failed()) {
  // SEND API REQUEST
  // Prepare your Firestore API request here
  
  // For example, to send a POST request to add a document to a Firestore collection:
  // Replace "your-project-id" with your actual project ID
  // Replace "your-collection" with the name of your Firestore collection
  // Replace "your-auth-token" with your Firebase authentication token
  
  String request = '{ "readings": {"gas": ' + gas + ', "temperature": ' + temperature + ', "humidity": ' + humidity + ', "intruder": ' + intruder + ', "lightIntensity": ' + lightintensity + ', "soilMoisture": ' + soilMoisture + ', "timestamp": ' + timestamp + '} }';

  Firebase.stream()
          .setToken("your-auth-token")
          .setProjectId("your-project-id")
          .addContentType(FIREBASE_JSON)
          .addHeader("X-HTTP-Method-Override: POST")
          .send("POST", "/v1/projects/your-project-id/databases/(default)/documents/your-collection", request);

  if (Firebase.success()) {
    Serial.println("API request sent to Firestore successfully!");
    Serial.print("Response code: ");
    Serial.println(Firebase.httpCode());
    Serial.print("Response: ");
    Serial.println(Firebase.responseString());
  } else {
    Serial.print("Error sending API request to Firestore: ");
    Serial.println(Firebase.error());
  }
} else {
  Serial.print("Error sending data to Firebase: ");
  Serial.println(Firebase.error());
}

    



  Program program1;
  program1.action = 0;
  program1.equipment = "pump";
  program1.limit = 50;
  program1.condition = 2;


  Program programs[] = {program1};
  programsLength = 1;
  
  for (int i = 0; i < programsLength; i++) {
    currProgram = programs[i];
    switch (currProgram.equipment) {
      case "pump":
      switch(currProgram.condition) {
        case 1:
          if (soilMoisture > currProgram.limit) {
            pumpToggle(1023, currProgram.action);
          }
        break;
        case 2:
          if (soilMoisture < currProgram.limit) {
            pumpToggle(1023, currProgram.action);
          }
        break;
        case 3:
          if (soilMoisture == currProgram.limit) {
            pumpToggle(1023, currProgram.action);
          }
        break;
      }
      break;
      case "fan":
      break;
      case "lamp":
      break;

    }
  }
  // CALL FUNCTIONS BASED ON THOSE

}