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
#define API_KEY "Your_API_Key"

// Insert Authorized Email and Corresponding Password
#define USER_EMAIL "board1@arduino.com"
#define USER_PASSWORD "12345678"


// Define your Firebase credentials
#define FIREBASE_HOST "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app/"

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

class Program {       
public:
  int action;
  int limit;
  String equipment;
  int condition;
};

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

void fetchPrograms(int programsLength, Program programs[], String programsPath) {
  Firebase.getJSON(fbdo, programsPath);
  if (Firebase.success()) {
    FirebaseJsonArray programsArray = fbdo.jsonObjectPtr()->getJsonArray("programs");
    int numPrograms = programsArray.size();
    
    // Loop through each program in the array
    for (int i = 0; i < numPrograms; i++) {
      FirebaseJsonObject programObj = programsArray.getJsonObject(i);
      
      // Extract program data from JSON object
      int action = programObj.getInt("action");
      int limit = programObj.getInt("limit");
      String equipment = programObj.getString("equipment");
      int condition = programObj.getInt("condition");

      // Create a Program object and add it to the programs array
      Program program;
      program.action = action;
      program.limit = limit;
      program.equipment = equipment;
      program.condition = condition;

      programs[i] = program; // Add program to array of programs
    }
    programsLength = numPrograms; // Update programsLength variable
  } else {
    Serial.print("Error fetching programs from Firebase: ");
    Serial.println(fbdo.errorReason());
  }
}

void printPrograms(int programsLength, Program programs[]) {
  Serial.println("Programs:");
  for (int i = 0; i < programsLength; i++) {
    Program program = programs[i];
    Serial.print("Program ");
    Serial.print(i + 1);
    Serial.print(": Action - ");
    Serial.print(program.action);
    Serial.print(", Limit - ");
    Serial.print(program.limit);
    Serial.print(", Equipment - ");
    Serial.print(program.equipment);
    Serial.print(", Condition - ");
    Serial.println(program.condition);
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
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  
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

void loop() {
  // Fetch and print programs
  String programsPath = databasePath + "/programs";
  Program programs[10]; // assuming maximum 10 programs
  int programsLength = 0;
  fetchPrograms(programsLength, programs, programsPath);
  printPrograms(programsLength, programs);

  // Add your program execution logic here
}


 // // Read sensor values
  // soilMoisture = (abs(1023 - analogRead(smPin)) / 1023) * 100;
  // humidity = dht.readHumidity();
  // temperature  = dht.readTemperature();
  // intruderDetected = digitalRead(irPin);
  // gas = map(analogRead(gasPin), 0, 1023, 0, 255);
  // phc = digitalRead(phcPin);

  // // SEND DATA TO DATABASE

  // // Prepare JSON data
  // json.clear();
  // json.addFloat("soilMoisture", soilMoisture);
  // json.addFloat("humidity", humidity);
  // json.addFloat("temperature", temperature);
  // json.addInt("intruderDetected", intruderDetected);
  // json.addInt("gas", gas);
  // json.addFloat("light", phc);

  // // Get current epoch time
  // timestamp = getTime();

  // // Define parent path
  // readingsPath = databasePath + boardNo + "/readings";
  // // 12345678/1/readings

  // // Set child paths
  // String tempDataPath = readingsPath + tempPath; // 12345678/1/readings/temperature
  // String humDataPath = readingsPath + humPath; 
  // String intrDataPath = readingsPath + intrPath;
  // String gasDataPath = readingsPath + gasPath;
  // String phcDataPath = readingsPath + phcPath;
  // String smDataPath = readingsPath + smPath;
  // String timeDataPath = readingsPath + timePath;
  

  // // Push data to Firebase
  // Firebase.setFloat(fbdo, tempDataPath, json.getFloat("temperature"));
  // Firebase.setFloat(fbdo, humDataPath, json.getFloat("humidity"));
  // Firebase.setInt(fbdo, presDataPath, json.getInt("intruder"));
  // Firebase.setFloat(fbdo, presDataPath, json.getFloat("soilMoisture"));
  // Firebase.setFloat(fbdo, presDataPath, json.getFloat("light"));
  // Firebase.setInt(fbdo, presDataPath, json.getInt("gas"));
  // Firebase.setInt(fbdo, timeDataPath, timestamp);






 // Handle errors, if any
//   if (Firebase.failed()) {
//     Serial.print("Error sending data to Firebase: ");
//     Serial.println(Firebase.error());
//   } else {
//   // SEND API REQUEST
//   // Prepare your Firestore API request here
  
//   // For example, to send a POST request to add a document to a Firestore collection:
//   // Replace "your-project-id" with your actual project ID
//   // Replace "your-collection" with the name of your Firestore collection
//   // Replace "your-auth-token" with your Firebase authentication token
  
//   String request = '{ "readings": {"gas": ' + gas + ', "temperature": ' + temperature + ', "humidity": ' + humidity + ', "intruder": ' + intruder + ', "lightIntensity": ' + lightintensity + ', "soilMoisture": ' + soilMoisture + ', "timestamp": ' + timestamp + '} }';

//   Firebase.stream()
//           .setToken("your-auth-token")
//           .setProjectId("your-project-id")
//           .addContentType(FIREBASE_JSON)
//           .addHeader("X-HTTP-Method-Override: POST")
//           .send("POST", "/v1/projects/your-project-id/databases/(default)/documents/your-collection", request);

//   if (Firebase.success()) {
//     Serial.println("API request sent to Firestore successfully!");
//     Serial.print("Response code: ");
//     Serial.println(Firebase.httpCode());
//     Serial.print("Response: ");
//     Serial.println(Firebase.responseString());
//   } else {
//     Serial.print("Error sending API request to Firestore: ");
//     Serial.println(Firebase.error());
//   }
// }


// // loop over all programs, apply each one

//   for (int i = 0; i < programsLength; i++) {
//     currProgram = programs[i];
//     switch (currProgram.equipment) {
//       case "pump":
//       switch(currProgram.condition) {
//         case 1:
//           if (soilMoisture > currProgram.limit) {
//             pumpToggle(currProgram.action);
//           }
//         break;
//         case 2:
//           if (soilMoisture < currProgram.limit) {
//             pumpToggle(currProgram.action);
//           }
//         break;
//       }
//       break;
//       case "fan":
//       switch(currProgram.condition) {
//         case 1:
//           if (temprature > currProgram.limit) {
//             fanToggle(currProgram.action);
//           }
//         break;
//         case 2:
//           if (soilMoisture < currProgram.limit) {
//             pumpToggle(currProgram.action);
//           }
//         break;
//       }
//       break;
//       case "lamp":
//          switch(currProgram.condition) {
//         case 1:
//           if (phc > currProgram.limit) {
//             LEDToggle(currProgram.action);
//           }
//         break;
//         case 2:
//           if (phc < currProgram.limit) {
//             LEDToggle(currProgram.action);
//           }
//         break;
//       }
//       break;
//     }
//   }
//   // CALL FUNCTIONS BASED ON THOSE