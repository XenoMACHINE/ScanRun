//
//  UserViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 01/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class UserViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    lazy var db = Firestore.firestore()

    var userId = UserManager.shared.userId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserUI()
    }
    
    func setUserUI(){
        guard let idUser = self.userId else { return }
        db.collection("users").document(idUser).getDocument { (snap, err) in
            guard let data = snap?.data() else { return }
            self.usernameLabel.text = data["username"] as? String
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
