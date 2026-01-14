// Use compat versions for Service Workers
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// You can actually import your config here too to avoid duplication!
const firebaseConfig = {
  apiKey: "AIzaSyCnlphOLXgUoDvXim5H8IA9CUbX7_ipK4c",
  authDomain: "tns-notif.firebaseapp.com",
  projectId: "tns-notif",
  storageBucket: "tns-notif.firebasestorage.app",
  messagingSenderId: "146195934050",
  appId: "1:146195934050:web:a04b6a79dc8353e7bd1a3b",
  measurementId: "G-T7XPEBE2QS"
};

// This check prevents crashes if the script is loaded before the Firebase SDK
if (typeof firebase !== 'undefined') {
  firebase.initializeApp(firebaseConfig);
}

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received: ', payload);
});