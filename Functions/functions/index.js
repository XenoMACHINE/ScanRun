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

    let found = false;
    let nbApiCalled = 0;
    const ean = req.params.ean;
    const nbApiToCall = 2;
    console.log("EAN : ", ean);

    //Try find in db
    db.collection('products').doc(ean).get()
        .then(doc => {
            nbApiCalled++;
            console.log("DATABASE");
            console.log("FOUND : ", found);
            if (!found) {
                if (!doc.exists) {
                    console.log("DB don't find");
                    if (nbApiCalled == nbApiToCall){
                        console.log("no product found anywhere");
                        return res.status(404).send('No product found');
                    }
                } else {
                    found = true;
                    console.log(doc.data());
                    res.send(doc.data());
                }
            }
        })
        .catch(err => {
            nbApiCalled++;
            console.log("DB don't find");
            if (nbApiCalled == nbApiToCall){
                console.log("no product found anywhere");
                return res.status(404).send('No product found');
            }
        });


    let url = "https://fr.openfoodfacts.org/api/v0/produit/" + ean + ".json"
    request(url, (error, resp, body) => {
        nbApiCalled++;
        console.log("OPEN FOOD FACTS");
        console.log(body);
        console.log("FOUND : ", found);
        if (!found){
            if (!error && resp.statusCode === 200) {
                let json = JSON.parse(body);
                if (json.status != 0){
                    found = true;
                    let product = json.items[0];
                    db.collection('products').doc(ean).set({
                        id: product.ean,
                        name: product.title,
                        brand: product.brand
                    });
                    return res.send(body);
                }else {
                    console.log("OPEN FOOD don't find");
                    if (nbApiCalled == nbApiToCall){
                        console.log("no product found anywhere");
                        res.status(404).send('No product found');
                    }
                }
            }else{
                console.log("OPEN FOOD don't find");
                if (nbApiCalled == nbApiToCall){
                    console.log("no product found anywhere");
                    return res.status(404).send('No product found');
                }
            }
        }
    });


    url = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + ean;
    request(url, (error, resp, body) => {
        nbApiCalled++;
        console.log("UPC ITEM DB");
        console.log(body);
        console.log("FOUND : ", found);
        if (!found) {
            if (!error && resp.statusCode === 200) {
                let json = JSON.parse(body);
                if (json.total > 0 && json.code != "INVALID_UPC") {
                    found = true;
                    console.log("SEND DATA TO DB");
                    let product = json.items[0];
                    db.collection('products').doc(ean).set({
                        id: product.ean,
                        name: product.title,
                        brand: product.brand
                    });
                    return res.send(body);
                }else {
                    console.log("UPC don't find");
                    if (nbApiCalled == nbApiToCall) {
                        console.log("no product found anywhere");
                        return res.status(404).send('No product found');
                    }
                }
            } else {
                console.log("UPC don't find 404");
                if (nbApiCalled == nbApiToCall){
                    console.log("no product found anywhere");
                    return res.status(404).send('No product found');
                }
            }
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