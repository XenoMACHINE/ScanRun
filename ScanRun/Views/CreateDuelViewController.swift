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
    @IBOutlet weak var timeTextfield: UITextField!
    @IBOutlet weak var timeSelector: UISegmentedControl!
    
    lazy var db = Firestore.firestore()
    
    var idFriend : String?
    var friendName = "un ami"
    var chooseProduct : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titletf.delegate = self
        timeTextfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshFriendBtn()
        refreshProductInfos()
    }
    
    func refreshFriendBtn(){
        searchFriendBtn.isEnabled = !switchPublic.isOn
        if switchPublic.isOn{
            searchFriendBtn.setTitle("Défi public", for: .normal)
        }else{
            searchFriendBtn.setTitle("Envoyer à \(friendName)", for: .normal)
        }
    }
    
    func refreshProductInfos(){
        guard let product = chooseProduct else { return }
        self.nameProductLabel.text = "\(product.name ?? "") - \(product.brand ?? "")"
        self.quantityLabel.text = product.quantity
        self.eanLabel.text = product.id
        if let image = product.loadedImage{
            self.imageProduct.image = image
        }else{
            loadProductImage()
        }
    }
    
    func loadProductImage(){
        guard let imgUrl = chooseProduct?.imageUrl else {
            NiceActivityIndicator().stopAnimating(self.imageProduct)
            return
        }
        
        self.imageProduct.downloaded(from: imgUrl, contentMode: .scaleAspectFill) {
            if self.imageProduct.image == nil {
                self.imageProduct.image = UIImage(named: "placeholder")
            }
            NiceActivityIndicator().stopAnimating(self.imageProduct)
        }
    }
    
    func getDuration() -> Int?{ //in seconds
        guard let durationTxt = timeTextfield.text, let duration = Int(durationTxt) else { return nil}
        var secDuration = duration
        
        switch timeSelector.selectedSegmentIndex{
        case 0:
            secDuration *= 60
        case 1:
            secDuration *= 3600
        case 2:
            secDuration *= (3600 * 24)
        default:
            secDuration *= 60
        }
        
        return secDuration
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onSwitchPublic(_ sender: Any) {
        refreshFriendBtn()
    }
    
    @IBAction func onLaunchDuel(_ sender: Any) {
        guard let idProduct = chooseProduct?.id,
            (switchPublic.isOn || idFriend != nil),
            let duration = getDuration()
            else { self.showAlert(title: "Remplissze tous les champs", message: "")
            return }
        var duel : [String : Any] = [
            "title"     : titletf.text ?? "",
            "isPublic"  : switchPublic.isOn,
            "idCreator" : UserManager.shared.userId ?? "",
            "idProduct" : idProduct,
            "duration"  : duration
        ]
        if let idChallenger = idFriend {
            duel["idChallenger"] = idChallenger
        }
        db.collection("duels").addDocument(data: duel)
        self.dismiss(animated: true)
    }
}

extension CreateDuelViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
