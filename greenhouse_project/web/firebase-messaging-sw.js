// firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyBY0-zEI4nI0gbmj-weP69UnXCWGkzwryM",
  authDomain: "greenhouse-ctrl-system.firebaseapp.com",
  projectId: "greenhouse-ctrl-system",
  storageBucket: "greenhouse-ctrl-system.appspot.com",
  messagingSenderId: "128457266349",
  appId: "1:128457266349:web:63f56fc3ec593413172224",
  measurementId: "G-Y4BXLWR3CV"
});

const messaging = firebase.messaging();

// messaging.onBackgroundMessage((payload) => {
//   console.log('[firebase-messaging-sw.js] Received background message ', payload);
//   const notificationTitle = payload.notification.title;
//   const notificationOptions = {
//     body: payload.notification.body,
//     icon: payload.notification.icon
//   };

//   self.registration.showNotification(notificationTitle, notificationOptions);
// });

messaging.setBackgroundMessageHandler(function (payload) {
  const promiseChain = clients
      .matchAll({
          type: "window",
          includeUncontrolled: true
      })
      .then(windowClients => {
          for (let i = 0; i < windowClients.length; i++) {
              const windowClient = windowClients[i];
              windowClient.postMessage(payload);
          }
      })
      .then(() => {
          return registration.showNotification("New Message");
      });
  return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
  console.log('notification received: ', event)
});
