importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCOjVNkRzlVyX6d9qQCcf1XIZfTQCGTIUM",
      authDomain: "likemind-58637.firebaseapp.com",
      projectId: "likemind-58637",
      storageBucket: "likemind-58637.appspot.com",
      messagingSenderId: "152355871827",
      appId: "1:152355871827:web:c7dbebe5bddd980f1e7aa6",
      measurementId: "G-X8G1N4RN9V",
      // databaseURL: "...",
  
  
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});