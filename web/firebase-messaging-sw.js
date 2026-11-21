importScripts("https://www.gstatic.com/firebasejs/11.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/11.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDcsSsjj0TyrzfcUxUwGebR0EsFYBzkVPg",
  authDomain: "strat3x-app.firebaseapp.com",
  projectId: "strat3x-app",
  storageBucket: "strat3x-app.firebasestorage.app",
  messagingSenderId: "704177767512",
  appId: "1:704177767512:web:067205084ec2cab245362d",
  measurementId: "G-QKTQ6CZ5PK",
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((message) => {
  console.log("[firebase-messaging-sw.js] Background message received:", message);
});
