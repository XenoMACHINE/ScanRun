const functions = require('firebase-functions');
const admin = require('firebase-admin');
const https = require('https');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

//Manage Auth
exports.autoCreateUser = functions.auth.user().onCreate((user) => {
  //functions.auth.user().onCreate(event => {
  const email = user.email; // The email of the user.
  const uid = user.uid;

  const collection = db.collection("users")
  collection.doc(uid).set({
    email : email,
    id : uid
  }).then(()=>{
    console.log("User created");
    return true;
  })
});

exports.autoDeleteUser = functions.auth.user().onDelete((user) => {
  db.collection("users").doc(user.uid).delete();
  console.log("User [" + user.email + ", " + user.uid + "] deleted");
  return true
});


//Callable from app
exports.getProduct = functions.https.onCall((data, context) => {

    const ean = data.ean;

    // Authentication / user information is automatically added to the request.
    const uid = context.auth.uid;
    const email = context.auth.token.email || null;

    https.get('https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY', (resp) => {
        let data = '';

        // A chunk of data has been recieved.
        resp.on('data', (chunk) => {
            data += chunk;
        });

        // The whole response has been received. Print out the result.
        resp.on('end', () => {
            console.log(JSON.parse(data).explanation);
            return { text: ean };
        });

    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
});