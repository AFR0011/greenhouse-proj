const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");

// Fetch the service account key JSON file contents
var serviceAccount = require("../greenhouse-ctrl-system-firebase-adminsdk-9eh50-d761bbaa6a.json");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(
    require("../greenhouse-ctrl-system-firebase-adminsdk-9eh50-d761bbaa6a.json")
  ),
  databaseURL:
    "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app/",
});

// Create Express app
const app = express();
app.use(express.json()); // Middleware to parse JSON bodies
app.use(bodyParser.json()); // Middleware to parse JSON bodies

// Define the port for your Express app
const PORT = process.env.PORT || 3000;

// Realtime database
const rtdb = admin.database();

// Firestore database
const firedb = admin.firestore();

// Endpoint to synchronize Cloud Firestore to Realtime Database
app.post("/sync/firestore-to-realtime", async (req, res) => {
  try {
    // Retrieve data from request body
    const newData = req.body;

    // Update corresponding data in Realtime Database
    await rtdb
      .ref(`/${newData.timestamp}/${newData.boardNo}/readings`)
      .set(newData);

    res.status(200).send("Data synchronized successfully.");
  } catch (error) {
    console.error("Error synchronizing data:", error);
    res.status(500).send("Internal server error.");
  }
});

// Endpoint to synchronize Realtime Database to Cloud Firestore
app.post("/sync/realtime-to-firestore", async (req, res) => {
  try {
    // Retrieve data from request body
    const newData = req.body;

    // Update corresponding document in Cloud Firestore
    await firedb
      .collection("readings")
      .doc(`${newData.timestamp}`)
      .set(newData);

    res.status(200).send("Data synchronized successfully.");
  } catch (error) {
    console.error("Error synchronizing data:", error);
    res.status(500).send("Internal server error.");
  }
});

// Endpoint to send notifications
app.post("/sendNotification", async (req, res) => {
  const { userId, title, body } = req.body;

  if (!userId || !title || !body) {
    return res
      .status(400)
      .send("Missing required parameters: userId, title, or body");
  }

  try {
    // Fetch the FCM token for the specified user
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      return res.status(404).send("User not found");
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      return res.status(400).send("FCM token not available for this user");
    }

    // Construct the notification message
    const message = {
      notification: {
        title: title,
        body: body,
      },
      token: fcmToken,
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
    return res.status(200).send("Notification sent successfully");
  } catch (error) {
    console.error("Error sending notification:", error);
    return res.status(500).send("Internal Server Error");
  }
});

// Start the Express app
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
