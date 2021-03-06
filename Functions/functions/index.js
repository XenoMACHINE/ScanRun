const functions = require('firebase-functions');
const admin = require('firebase-admin');
const request = require('request');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();

// Automatically allow cross-origin requests

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

//Manage Auth
exports.autoCreateUser = functions.region('europe-west1').auth.user().onCreate((user) => {
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

exports.autoDeleteUser = functions.region('europe-west1').auth.user().onDelete((user) => {
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

function findInDB(ean, res){
    db.collection('products').doc(ean).get()
        .then(doc => {
            console.log("DATABASE");
            if (!doc.exists) {
                console.log("DB don't find");
                findInOpenFoodFacts(ean, res);
                //return res.status(404).send('No product found');
            } else {
                console.log(doc.data());
                return res.send(doc.data());
            }
        })
        .catch(err => {
            console.log("DB don't find");
            findInOpenFoodFacts(ean, res);
            //return res.status(404).send('No product found');
        });
}

function findInOpenFoodFacts(ean, res){
    let url = "https://fr.openfoodfacts.org/api/v0/produit/" + ean + ".json"
    request(url, (error, resp, body) => {
        console.log("OPEN FOOD FACTS");
        console.log(body);
        if (!error && resp.statusCode === 200) {
            let json = JSON.parse(body);
            let product = json.product;
            if (json.status != 0){
                if (product.id != undefined){
                    let post = {
                        id: product.id,
                        name: product.product_name || product_name_fr || product.generic_name_fr || product.generic_name || "",
                        brand: product.brands || ""
                    };
                    if (ean.length == 13) {
                        let tmp = ean.slice(0, 3) + "/" + ean.slice(3, 6) + "/" + ean.slice(6, 9) + "/" + ean.slice(9, 13);
                        url = "https://static.openfoodfacts.org/images/products/" + tmp + "/1.400.jpg"
                        post["image"] = url;
                    }
                    console.log(post);
                    db.collection('products').doc(ean).set(post);
                    return res.send(post);
                }
                return res.send(body);
            }else {
                console.log("OPEN FOOD don't find");
                findInUpcItem(ean, res);
            }
        }else{
            console.log("OPEN FOOD don't find");
            findInUpcItem(ean, res);
            //return res.status(404).send('No product found');
        }
    });
}

function findInUpcItem(ean, res) {
    let url = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + ean;
    request(url, (error, resp, body) => {
        console.log("UPC ITEM DB");
        console.log(body);
        if (!error && resp.statusCode === 200) {
            let json = JSON.parse(body);
            if (json.total > 0 && json.code != "INVALID_UPC") {
                console.log("SEND DATA TO DB");
                let product = json.items[0];
                let post = {
                    id: product.ean,
                    name: product.title,
                    brand: product.brand
                };
                db.collection('products').doc(ean).set(post);
                return res.send(post);
            }else {
                console.log("UPC don't find");
                //findInOpenFoodFacts();
                return res.status(404).send('No product found');
            }
        } else {
            console.log("UPC don't find 404");
            //findInOpenFoodFacts();
            return res.status(404).send('No product found');
        }
    });
}

let getProduct = (req, res) => {
    const ean = req.params.ean;
    //console.log("EAN : ", ean);

    //Try find in db
    findInDB(ean, res); //Test db then openfoodfact then UpcItem
};

let getMedia = (req, res) => {
    db.collection("medias").doc("LOOhWcaMFWXGaWAfn0px").get().then(doc => {
        return res.send(doc.data());
    })
}

let emptyRequest = (req, res) => {
    return res.status(200).send("OK");
};

let sendProduct = (req, res) =>{
    const brand = req.body.brand;
    console.log(req.body);
};

let sendNotif = (req, res) => {

    const idTargetUser = req.body.id;
    const username = req.body.username;// || "Un joueur";
    db.collection("users").doc(idTargetUser).get()
        .then(doc => {
            console.log(doc.data())
            const FCMToken = doc.data()["FCMToken"];
            const payload = {
                notification: {
                    title: username + " vous défie !",
                    body: "Ouvrez l'application pour voir le défie !"
                }
            };
            admin.messaging().sendToDevice(FCMToken, payload);
        });
};


//Config
app.use(cors({ origin: true }));
app.use(authenticate);

//Roots
app.get('/emptyRequest', emptyRequest);
app.get('/getProduct/:ean', getProduct);
app.get('/getMediaTest', getMedia);
app.post('/sendProduct', bodyParser.json(), sendProduct);
//app.post('/sendNotif', bodyParser.json(), sendNotif);

//Deploy
exports.api = functions
    .region('europe-west1')
    .https.onRequest(app);