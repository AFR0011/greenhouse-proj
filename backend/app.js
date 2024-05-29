const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");
const path = require("path");

// Fetch the service account key JSON file contents
var serviceAccount = require("../greenhouse-ctrl-system-firebase-adminsdk-9eh50-d761bbaa6a.json");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app/",
});

// Create Express app
const app = express();
app.use(express.json());
app.use(bodyParser.json());

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, "public")));

// Define the port for your Express app
const PORT = process.env.PORT || 3000;

// Realtime database
const rtdb = admin.database();

// Firestore database
const firedb = admin.firestore();

// Endpoint to synchronize Cloud Firestore to Realtime Database
app.post("/sync/firestore-to-realtime", async (req, res) => {
  try {
    // Get current timestamp
    const timestamp = Date.now();

    // Retrieve all data from Firestore collection matching req.body.data
    const collection = req.body.data;
    const snapshot = await firedb.collection(collection).get();
    if (collection == "equipment") {
      var equipment = {};
      var boardNo = 1;
      // Iterate over the documents in the snapshot
      snapshot.docs.forEach((doc) => {
        const docData = doc.data();
        const equipmentKey = docData.type;
        equipment[equipmentKey] = docData.status;
        boardNo = docData.board;
      });

      rtdb.ref(`${timestamp}/${boardNo}/equipment`).set(equipment);

      res.status(200).json({
        timestamp,
        equipment,
      });
    } else {
      var programs = {};
      var boardNo = 1;
      // Iterate over the documents in the snapshot
      snapshot.docs.forEach((doc) => {
        const docData = doc.data();
        const programKey = docData.title;
        programs[programKey] = {
          action: docData.action,
          limit: docData.limit,
          equipment: docData.equipment,
          condition: docData.condition,
        };
      });

      rtdb.ref(`${timestamp}/${boardNo}/programs`).set(programs);

      // Send the programs object as a response
      res.status(200).json({
        timestamp,
        programs,
      });
    }
  } catch (error) {
    // Handle errors and send an appropriate response
    console.error("Error syncing Firestore to Realtime Database:", error);
    res.status(500).json({
      error: "Failed to sync Firestore to Realtime Database",
      details: error.message,
    });
  }
});

// Endpoint to synchronize Realtime Database to Cloud Firestore
app.post("/sync/realtime-to-firestore", async (req, res) => {
  try {
    // Get current timestamp
    const timestamp = Date.now();

    // Retrieve req.body as new readings
    const newData = req.body;

    // Set data in firestore database in the collection "readings" with the id of timestamp
    await firedb.collection("readings").doc(`${timestamp}`).set(newData);

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
