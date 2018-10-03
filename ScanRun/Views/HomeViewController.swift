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

class HomeViewController: UIViewController {

    lazy var db = Firestore.firestore()
    lazy var functions = Functions.functions()
    lazy var storage = Storage.storage()
    var dbArray : [[String:Any]] = []
    
    var duelArray : [Duel] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var viewMenu = UIView()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ScanRun"
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        drawMenu()
        getPublicDuels()
        
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.white.cgColor
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
    
    func getPublicDuels(){
        NiceActivityIndicatorBuilder().setColor(UIColor.white).build().startAnimating(tableView)
        DuelManager.shared.getPublicDuels { (duels) in
            self.duelArray = duels
            NiceActivityIndicator().stopAnimating(self.tableView)
        }
    }
    
    func drawMenu() {
        viewMenu.subviews.forEach({ $0.removeFromSuperview() }) // remove all subviews
        viewMenu.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let imageView = UIImageView(frame: viewMenu.frame)
        imageView.image = UIImage(named: "iconMenu")
        viewMenu.addSubview(imageView)
        
        let tapGestureRecognizerDeconnect = UITapGestureRecognizer(target: self, action: #selector(goToMenu))
        viewMenu.addGestureRecognizer(tapGestureRecognizerDeconnect)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: viewMenu)
    }
    
    @objc func goToMenu() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
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
    
}

extension UITextField {
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

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return duelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DuelTableViewCell", for: indexPath) as? DuelTableViewCell else { return UITableViewCell() }
        
        cell.setup(duel:duelArray[indexPath.row])
        
        return cell
    }
    
}
