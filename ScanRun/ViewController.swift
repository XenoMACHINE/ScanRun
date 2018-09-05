//
//  ViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 04/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAuth

class ViewController: UIViewController {

    lazy var db = Firestore.firestore()
    lazy var functions = Functions.functions()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        //testFirestore()
        Auth.auth().signInAnonymously { (result, error) in
            self.testCallFirebaseFunction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToScan(segue: UIStoryboardSegue) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "scan") as! ScanViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }


    func testFirestore(){
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func testCallFirebaseFunction(){
        functions.httpsCallable("getProduct").call(["ean": "0711719937364"]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("\(String(describing: code)) - \(message) - \(String(describing: details))")
                }
            }
            if let response = (result?.data as? [String: Any])?["response"] as? String {
                print(response)
            }
        }
    }
}
