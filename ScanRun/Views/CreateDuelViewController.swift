//
//  CreateDuelViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 04/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CreateDuelViewController: UIViewController {

    @IBOutlet weak var titletf: UITextField!
    @IBOutlet weak var searchFriendBtn: UIButton!
    @IBOutlet weak var switchPublic: UISwitch!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var eanLabel: UILabel!
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    
    var idFriend : String?
    var friendName = "un ami"
    var chooseProduct : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titletf.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshFriendBtn()
    }
    
    func refreshFriendBtn(){
        searchFriendBtn.isEnabled = !switchPublic.isOn
        if switchPublic.isOn{
            searchFriendBtn.setTitle("Défi public", for: .normal)
        }else{
            searchFriendBtn.setTitle("Envoyer à \(friendName)", for: .normal)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onSwitchPublic(_ sender: Any) {
        refreshFriendBtn()
    }
    
    @IBAction func onLaunchDuel(_ sender: Any) {
        guard let idProduct = chooseProduct?.id,
            (switchPublic.isOn || idFriend != nil)
            else { self.showAlert(title: "Remplissze tous les champs", message: "")
            return }
        var duel : [String : Any] = [
            "title"     : titletf.text ?? "",
            "isPublic"  : switchPublic.isOn,
            "idCreator" : UserManager.shared.userId ?? "",
            "idProduct" : idProduct,
            "duration"  : 3600
        ]
        if let idChallenger = idFriend {
            duel["idChallenger"] = idChallenger
        }
        db.collection("duels").addDocument(data: duel)
    }
}

extension CreateDuelViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
