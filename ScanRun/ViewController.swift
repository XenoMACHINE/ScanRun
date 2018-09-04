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

class ViewController: UIViewController {

    lazy var db = Firestore.firestore()
    lazy var functions = Functions.functions()

    override func viewDidLoad() {
        super.viewDidLoad()
        //db = Firestore.firestore()
        testFirestore()
        testCallFirebaseFunction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        functions.httpsCallable("addMessage").call(["text": "test"]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("\(code) - \(message) - \(details)")
                }
            }
            if let text = (result?.data as? [String: Any])?["text"] as? String {
                print(text)
            }
        }
    }
}

