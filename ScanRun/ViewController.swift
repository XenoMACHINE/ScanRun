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
import SideMenu

class ViewController: UIViewController {

    lazy var db = Firestore.firestore()
    lazy var functions = Functions.functions()
    lazy var storage = Storage.storage()
    var dbArray : [[String:Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ScanRun"
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        //testFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let signInSingUpViewController = storyBoard.instantiateViewController(withIdentifier: "SignInSingUpViewController") as! SignInSingUpViewController
            self.present(signInSingUpViewController, animated: true)
        }else{
            UserManager.shared.setToken()
        }
        
        waitDuel()
    }
    
    @IBAction func onDisconnect(_ sender: Any) {
        try? Auth.auth().signOut()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signInSingUpViewController = storyBoard.instantiateViewController(withIdentifier: "SignInSingUpViewController") as! SignInSingUpViewController
        self.present(signInSingUpViewController, animated: true)
    }
    
    @IBAction func goToScan(segue: UIStoryboardSegue) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "scan") as! ScanViewController
        //self.navigationController?.pushViewController(nextViewController, animated: true)
        self.present(nextViewController, animated: true)
    }
    
    func waitDuel(){
        if let userId = UserManager.shared.userId{
            db.collection("duels")
                .whereField("userTarget", isEqualTo: userId)
                .whereField("closed", isEqualTo: false).addSnapshotListener({ (snapshot, error) in
                    for snap in snapshot?.documents ?? []{
                        if let userId = snap.data()["userLaunch"] as? String{
                            let validAction = UIAlertAction(title: "Voir", style: .cancel, handler: { (action) in
                                print("Go to duel")
                            })
                            
                            self.showAlert(title: "Vous venez de recevoir un duel !", message: "Alex vous défie !", actions: [validAction])
                        }
                    }
                })
        }

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
    
    func pushIndex(i : Int){
        
        let jsonObj = dbArray[i]
        if let id = jsonObj["id"] as? String{
            db.collection("products").document(id).setData(jsonObj, merge : true)
        }
        
        if i % 1000 == 0 {
            print("########## IN PROGRESS ########## --- \(i)\n")
        }
        
        if i == 9000 { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
            self.pushIndex(i: i+1)
        }
    }
    
    func testJsonToDB(){
//        db.collection("products").getDocuments { (snapshot, error) in
//            print(snapshot?.count)
//        }
//        return
        
        var json : JSON = []
        //let storageRef = storage.reference()
        if let path = Bundle.main.path(forResource: "myjsonfile", ofType: "json"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                json = JSON(data: data)
                
                if let array = json.arrayObject as? [[String:Any]]{
                    dbArray = array
                    pushIndex(i: 0)
                    return
                }
                
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
//                            if id == "5000112554359"{
//                                print(jsonObj)
//                            }
                            db.collection("products").document(id).setData(jsonObj, merge : true)
                        }
                        
                        count += 1
                        if count % 10000 == 0 {
                            print("########## IN PROGRESS ########## --- \(count)\n")
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

extension UITextField
{
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 3.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

