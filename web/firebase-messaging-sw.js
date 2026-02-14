importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
    // Burası boş bırakılabilir, Firebase JS SDK otomatik olarak algılayacaktır
    // veya firebase_options.dart içindeki değerler buraya eklenebilir.

     apiKey: 'AIzaSyCCW0cy94JOgfftraIOwILwTqisRl7FnwA',
        appId: '1:1001866780856:web:2d8ca866f200728f86144d',
        messagingSenderId: '1001866780856',
        projectId: 'unic-otantic-e4f32',
        authDomain: 'unic-otantic-e4f32.firebaseapp.com',
        databaseURL: 'https://unic-otantic-e4f32-default-rtdb.firebaseio.com',
        storageBucket: 'unic-otantic-e4f32.appspot.com',
        measurementId: 'G-J8PW23J36R',
});

const messaging = firebase.messaging();
