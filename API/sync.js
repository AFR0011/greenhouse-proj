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

// Express.js example
const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
admin.initializeApp();

const app = express();
app.use(bodyParser.json());

// Endpoint to synchronize Cloud Firestore to Realtime Database
app.post('/sync/firestore-to-realtime', async (req, res) => {
    try {
        // Retrieve data from request body
        const newData = req.body;

        // Update corresponding data in Realtime Database
        await admin.database().ref(`path/to/realtimeDB/${newData.id}`).set(newData);

        res.status(200).send('Data synchronized successfully.');
    } catch (error) {
        console.error('Error synchronizing data:', error);
        res.status(500).send('Internal server error.');
    }
});

// Endpoint to synchronize Realtime Database to Cloud Firestore
app.post('/sync/realtime-to-firestore', async (req, res) => {
    try {
        // Retrieve data from request body
        const newData = req.body;

        // Update corresponding document in Cloud Firestore
        await admin.firestore().doc(`collection/${newData.id}`).set(newData);

        res.status(200).send('Data synchronized successfully.');
    } catch (error) {
        console.error('Error synchronizing data:', error);
        res.status(500).send('Internal server error.');
    }
});

// Start the server
const port = 3000;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
