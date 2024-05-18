const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnMessage = functions.firestore
    .document('messages/{messageId}')
    .onCreate((snap, context) => {
        const newValue = snap.data();

        const message = {
          notification: {
            title: 'New Message',
            body: newValue.content || 'You have a new message.'
          },
          token: "FCM TOKEN OF MESSAGE RECEIVER" //INCLUDE FCM TOKENS IN DATABASE AND USE THEM HERE
        };

        return admin.messaging().send(message)
          .then(response => console.log('Successfully sent message:', response))
          .catch(error => console.log('Error sending message:', error));
    });