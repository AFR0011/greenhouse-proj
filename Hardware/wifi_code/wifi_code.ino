#include "Adafruit_Sensor.h"
#include "DHT.h"
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <FirebaseClient.h>
#include <NTPClient.h>
#include <WiFiUDP.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

#define BoardNo "1"



// Configuration data encapsulated
struct Config {
  String ssid;
  String password;
  String apiKey;
  String userEmail;
  String userPassword;
  String databaseUrl;
};

Config config = {
  .ssid = "Jazzy'",
  .password = "Incorrect92",
  .apiKey = "AIzaSyBOHR4kL1aHMVQBjXTW5Lq8piFrJLGYPeI",
  .userEmail = "board1@arduino.com",
  .userPassword = "12345678",
  .databaseUrl = "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app"
};



// App callback function prototypes
void asyncCB(AsyncResult &aResult);
void printResult(AsyncResult &aResult);


// network and ssl_client for setting up AsyncClient
DefaultNetwork network;

// Define AsynClient and UserAuth to initialize app instance
UserAuth user_auth(config.apiKey, config.userEmail, config.userPassword, 3000);

// App instance
FirebaseApp app;

// WiFi SSL
#if defined(ESP32) || defined(ESP8266) || defined(ARDUINO_RASPBERRY_PI_PICO_W)
#include <WiFiClientSecure.h>
WiFiClientSecure ssl_client;
#elif defined(ARDUINO_ARCH_SAMD) || defined(ARDUINO_UNOWIFIR4) || defined(ARDUINO_GIGA) || defined(ARDUINO_PORTENTA_C33) || defined(ARDUINO_NANO_RP2040_CONNECT)
#include <WiFiSSLClient.h>
WiFiSSLClient ssl_client;
#endif

// Async client
AsyncClientClass aClient(ssl_client, getNetwork(network));

// Create an instance of the RealtimeDatabase class
RealtimeDatabase Database;

// Async result class
AsyncResult aResult_no_callback;

// Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

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
unsigned long timerDelay = 30000;

// Readings database child nodes
String tempPath = "/temperature";
String humPath = "/humidity";
String intrPath = "/intruder";
String phcPath = "/light";
String gasPath = "/gas";
String smPath = "/soilMoisture";
String timePath = "/timestamp";


void connectToWiFi(const String &ssid, const String &password) {
  WiFi.begin(ssid.c_str(), password.c_str());

  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
}

int getTime() {
  timeClient.update();
  return timeClient.getEpochTime();
}

// Async callback for getting programs
void programsCallback(AsyncResult &Result) {
  if (Result.isError()) {
    Serial.print("Failed to get programs data: ");
    Serial.println(Result.error().message());
    return;
  }

  // Parse the JSON and get "1/programs"
  StaticJsonDocument<1024> doc;  // Adjust the size as needed
  DeserializationError error = deserializeJson(doc, Result.c_str());
  if (error) {
    Serial.print("Failed to parse JSON: ");
    Serial.println(error.c_str());
    return;
  }

  // Get programs' data
  JsonObject programs = doc[String(BoardNo)]["programs"];
  if (programs.isNull()) {
    Serial.println("No program data found.");
    return;
  }

  // Create list of programs and send to Arduino through serial communication
  for (JsonPair kv : programs) {
    JsonObject program = kv.value().as<JsonObject>();

    // Extract each detail from the program
    int action = program["action"];
    int condition = program["condition"];
    const char *equipment = program["equipment"];
    int limit = program["limit"];

    // Create the program data string
    String programData = String(action) + "," + String(condition) + "," + String(equipment) + "," + String(limit);

    // Send the program data to Arduino through serial communication
    Serial.println(programData);
  }
}


void equipmentCallback(AsyncResult &Result) {
  if (Result.isError()) {
    Serial.print("Failed to get equipment data: ");
    Serial.println(Result.error().message());
    return;
  }

  // Parse the JSON and get "1/EQUIPMENT"
  StaticJsonDocument<512> doc;  // Adjust the size as needed
  DeserializationError error = deserializeJson(doc, Result.c_str());
  if (error) {
    Serial.print("Failed to parse JSON: ");
    Serial.println(error.c_str());
    return;
  }

  // Assume equipment data is in "1/EQUIPMENT" path
  JsonObject equipment = doc["1"]["equipment"];
  if (equipment.isNull()) {
    Serial.println("No equipment data found.");
    return;
  }
  Serial.println(Result.c_str());
}
void sendPostRequest(String readings) {
  if (WiFi.status() == WL_CONNECTED) {  // Check WiFi connection status
    WiFiClientSecure client;
    HTTPClient http;

    // Specify the URL
    http.begin(client, "https://greenhouse-5b1d55d4ffae.herokuapp.com/sync/realtime-to-firestore");

    // Specify content-type header
    http.addHeader("Content-Type", "application/json");

    // Send HTTP POST request
    int httpResponseCode = http.POST(readings);

    // Check the response code
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("HTTP Response code: " + String(httpResponseCode));
      Serial.println("Response: " + response);
    } else {
      Serial.println("Error on sending POST: " + String(httpResponseCode));
    }

    // Free resources
    http.end();
  } else {
    Serial.println("WiFi Disconnected");
  }
}
void setup() {

  Serial.begin(115200);
  Serial.println("Starting setup...");

  connectToWiFi(config.ssid, config.password);
  Serial.println("Connected to WiFi.");

#if defined(ESP32) || defined(ESP8266) || defined(PICO_RP2040)
  ssl_client.setInsecure();
#if defined(ESP8266)
  ssl_client.setBufferSizes(4096, 1024);
#endif
#endif

  app.setCallback(asyncCB);

  initializeApp(aClient, app, getAuth(user_auth));

  unsigned long ms = millis();
  while (app.isInitialized() && !app.ready() && millis() - ms < 120 * 1000)
    ;
  Serial.println("App is ready.");
  Serial.println("App is initialized.");

  app.getApp<RealtimeDatabase>(Database);

  Database.url(config.databaseUrl);

  Serial.println("Realtime database setup complete.");
}

void loop() {
  String input;
  String databaseInput;
  JsonDocument receivedDoc;
  timestamp = getTime();

  // For connection and authentication
  app.loop();
  Database.loop();


  // Get latest entry for  and equipment and pass them to functions
  DatabaseOptions options;
  options.filter.limitToLast(1);
  Serial.println("Attempting to get programs data...");
  Database.get(aClient, "" + String(BoardNo) + "/programs", options, programsCallback);
  delay(30000);
  Serial.println("Programs data request sent.");

  Serial.println("Attempting to get equipment data...");
  Database.get(aClient, "" + String(BoardNo) + "/equipment", options, equipmentCallback);
  delay(30000);
  Serial.println("Equipment data request sent.");



  if (Serial.available() > 0) {
    input = Serial.readStringUntil('\n');
    const auto deser_err = deserializeJson(receivedDoc, input);
    if (!deser_err.c_str()) {
      // Convert received JSON to string
      serializeJson(receivedDoc, databaseInput);
      sendPostRequest(databaseInput);

      Database.set(aClient, "" + String(timestamp) + "/" + String(BoardNo) + "readings", databaseInput, asyncCB);
      delay(15000);
    }
  }
}

void asyncCB(AsyncResult &aResult) {
  if (aResult.appEvent().code() > 0) {
    Firebase.printf("Event task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.appEvent().message().c_str(), aResult.appEvent().code());
  }

  if (aResult.isDebug()) {
    Firebase.printf("Debug task: %s, msg: %s\n", aResult.uid().c_str(), aResult.debug().c_str());
  }

  if (aResult.isError()) {
    Firebase.printf("Error task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.error().message().c_str(), aResult.error().code());
  }
}