const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.autoCreateUser = functions.auth.user().onCreate(event => {

  const user = event.data; // The Firebase user.
  const email = user.email; // The email of the user.
  const uid = user.uid;

  return admin.firestore().document("users/"+uid+"email").set(email);
  //return admin.database().ref("/users/"+uid+"/mail").set(email);
});
