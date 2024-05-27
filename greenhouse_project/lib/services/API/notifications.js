const express = require("express");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

// Create Express app
const app = express();
app.use(express.json()); // Middleware to parse JSON bodies

// Define the port for your Express app
const PORT = process.env.PORT || 3000;

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
