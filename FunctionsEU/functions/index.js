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
            } else {
                return res.status(200).send(doc.data());
            }
        })
        .catch(err => {
            console.log("DB don't find");
            findInOpenFoodFacts(ean, res);
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
                    console.log("SEND DATA TO DB");
                    let post = {
                        id: ean,
                        name: product.product_name || product_name_fr || product.generic_name_fr || product.generic_name || "",
                        brand: product.brands || ""
                    };
                    if (ean.length == 13) {
                        let tmp = ean.slice(0, 3) + "/" + ean.slice(3, 6) + "/" + ean.slice(6, 9) + "/" + ean.slice(9, 13);
                        post["image"] = "https://static.openfoodfacts.org/images/products/" + tmp + "/1.400.jpg";
                    }
                    console.log(post);
                    db.collection('products').doc(ean).set(post);
                    return res.status(200).send(post);
                }
                return res.status(200).send(body);
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
                    id: ean,
                    name: product.title,
                    brand: product.brand
                };
                db.collection('products').doc(ean).set(post);
                return res.status(200).send(post);
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
    const ean = req.body.ean;
    const name = req.body.name;
    const brand = req.body.brand;
    const quantity = req.body.quantity;
    const image = req.body.imgUrl;

    if (ean == undefined || name == undefined || ean.length == 0 || name.length == 0) {
        return res.status(400).send("POST EXEMPLE [*NEEDED] \n\n*ean : 01234567891234\n*name : Coca Cola zero 1L\nbrand : Coca Cola\nquantity : 1L\nimgUrl : https://images/1234.png")
    }

    let post = {
        id: ean,
        name: name
    };

    if (brand != undefined) { post["brand"] = brand }
    if (quantity != undefined) { post["quantity"] = quantity }
    if (image != undefined) { post["image"] = image }

    db.collection('products').doc(ean).set(post).then(()=>{
            console.log("Product created/updated")
        })
    return res.status(201).send(post);
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
//app.use(authenticate);

//Roots
app.get('/emptyRequest', emptyRequest);
app.get('/getProduct/:ean', getProduct);
app.get('/getMediaTest', getMedia);
app.post('/sendProduct', sendProduct);
//app.post('/sendNotif', bodyParser.json(), sendNotif);

//Deploy
exports.api = functions
    .region('europe-west1')
    .https.onRequest(app);