const functions = require('firebase-functions');
const admin = require('firebase-admin');
const request = require('request');
const express = require('express');
const cors = require('cors');
const app = express();

// Automatically allow cross-origin requests

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
/*exports.getProduct = functions.https.onCall((data, context) => {

    const ean = data.ean;

    // Authentication / user information is automatically added to the request.
    const uid = context.auth.uid;
    const email = context.auth.token.email || null;
    var url = "https://fr.openfoodfacts.org/api/v0/produit/" + ean + ".json"

    request(url, (error, resp, body) => {
        if (!error && resp.statusCode === 200) {
            // C'est ok
            console.log("OPEN FOOD FACTS");
            console.log(body);
            return { text: body };
        }
    });

    url = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + ean;
    request(url, (error, resp, body) => {
      if (!error && resp.statusCode === 200) {
          // C'est ok
          console.log("UPC ITEM DB");
          console.log(body);

          return { text: body };
      }else{
          return error;
      }
    });
}); */

let authenticate = (req, res, next) => {
    if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
        res.status(403).send('Unauthorized');
        return;
    }
    const idToken = req.headers.authorization.split('Bearer ')[1];
    admin.auth().verifyIdToken(idToken)
        .then((decoded) => {
            req.user = decoded;
            next();
        })
        .catch((err) => {
            res.status(401).send(err);
        });
};

let getProduct = (req, res) => {

    const ean = req.params.ean;
    let url = "https://fr.openfoodfacts.org/api/v0/produit/" + ean + ".json"


    url = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + ean;

    request(url, (error, resp, body) => {
        if (!error && resp.statusCode === 200) {
            // C'est ok
            console.log("UPC ITEM DB");
            console.log(body);

            res.send(body);
        }else{
            res.status(500).send(error);
        }
    });
};

//Config
app.use(cors({ origin: true }));
app.use(authenticate);

//Roots
app.get('/getProduct/:ean', getProduct);

//Deploy
exports.api = functions.https.onRequest(app);