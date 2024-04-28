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
const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const getRealtimeDatabase = require('firebase-admin/database');

initializeApp();

const db = getFirestore();
const realtime_db = getRealtimeDatabase();




const app = express();
app.use(bodyParser.json());


//firebase classes
// Equipment class
class Equipment {
    constructor(board, status, type) {
        this.board = board; // integer
        this.status = status; // boolean
        this.type = type; // string
    }
}

// Programs class
class Programs {
    constructor(action, condition, limit, equipment, creationDate, title) {
        this.action = action; // {fan: string, light: string}
        this.condition = condition; // {gas: string, temperature: string}
        this.limit = limit; // {gas: string, temperature: string}
        this.equipment = equipment; // {gas: string, temperature: string}
        this.creationDate = creationDate; // Date object
        this.title = title; // string
    }
}

// Readings class
class Readings {
    constructor(boardNo, readings, timestamp) {
        this.boardNo = boardNo
        this.readings = readings; // {gas: integer, humidity: float, intruder: boolean, lightIntensity: integer, soilMoisture: float, temperature: float, timestamp: integer}
        this.timestamp = timestamp //
    }
}



// Endpoint to synchronize Cloud Firestore to Realtime Database
app.post('/sync/firestore-to-realtime', async (req, res) => {
    try {
        // Retrieve data from request body
        const newData = req.body;

        // Update corresponding data in Realtime Database
        await realtime_db.ref(`/${newData.timestamp}/${newData.boardNo}`).set(newData);

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
        await db.collection('readings').doc(`${newData.timestamp}`).set(newData);

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
