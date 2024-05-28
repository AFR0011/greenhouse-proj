    /**
     * API to synchronize data between Realtime Database and Cloud Firestore.
     *
     */

    /*
        Paths to define (TODO):
    - sync to realtime:
        - Sync latest program details whenever app sends a request to API (i.e., whenever a user CRUDs a program)
    - sync to firestore:
        - Sync latest sensor readings and equipment status whenever ESP module sends data to realtime database
        - Send a request to API whenever realtime database is updated 
    */
    const express = require("express");
    const bodyParser = require("body-parser");
    const admin = require("firebase-admin");


    // Fetch the service account key JSON file contents
    var serviceAccount = require("./greenhouse-ctrl-system-firebase-adminsdk-9eh50-d761bbaa6a.json");

    // Initialize the app with a service account, granting admin privileges
    admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // The database URL depends on the location of the database
    databaseURL: "https://greenhouse-ctrl-system-default-rtdb.europe-west1.firebasedatabase.app/",
    });


    // Realtime database
    var rtdb = admin.database();

    // Firestore database
    var firedb = getFirestore();

    const app = express();
    app.use(bodyParser.json());

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
        await firedb.collection("readings").doc(`${newData.timestamp}`).set(newData);

        res.status(200).send("Data synchronized successfully.");
    } catch (error) {
        console.error("Error synchronizing data:", error);
        res.status(500).send("Internal server error.");
    }
    });

    // Start the server
    const port = 3000;
    app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
    });
