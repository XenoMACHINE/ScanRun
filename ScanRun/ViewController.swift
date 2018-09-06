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
import FirebaseStorage
import Alamofire

class ViewController: UIViewController {

    lazy var db = Firestore.firestore()
    lazy var functions = Functions.functions()
    lazy var storage = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        //testFirestore()
        Auth.auth().signIn(withEmail: "test@test.fr", password: "azerty12") { (result, error) in
            result?.user.getIDToken(completion: { (idToken, error) in
                if let token = idToken{
                    UserManager.shared.token = token
                    //self.testJsonToDB()
                    //self.testCallFirebaseFunction()
                }
            })
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
        let url = "https://us-central1-scanrun-5f26e.cloudfunctions.net/api/getProduct/3274080005003"
        let headers : HTTPHeaders = ["Authorization":"Bearer \(UserManager.shared.token ?? "")"]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                print(response)
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func testJsonToDB(){
        var json : JSON = []
        //let storageRef = storage.reference()
        if let path = Bundle.main.path(forResource: "myjsonfile", ofType: "json"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                json = JSON(data: data)
                
                var count = 0
                for obj in json.arrayObject ?? []{
                    if var jsonObj = obj as? [String:Any]{
//
//                        if let imageUrl = jsonObj["image"] as? String{
//                            jsonObj["image"] = nil
//                            storageRef.child("images")
//                        }
//
                        if let id = jsonObj["id"] as? String{
                            db.collection("products").document(id).setData(jsonObj, merge : true)
                        }
                        
                        count += 1
                        
                        if count % 1000 == 0 {
                            print(count)
                            print(jsonObj)
                            print("########## IN PROGRESS ########## \n")
                        }
                        
                    }
                }
                
                if json == JSON.null {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
}

