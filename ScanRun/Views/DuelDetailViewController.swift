//
//  DuelDetailViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 22/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DuelDetailViewController: UIViewController {
    
    //Duel
    @IBOutlet weak var titleLabel: UILabel!
    
    //Product
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var produtBrandLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    
    //Creator
    @IBOutlet weak var creatorView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    var duel : Duel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        productView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToProduct)))
        creatorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToCreator)))
    }
    
    @objc func goToProduct(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        controller.productId = duel?.idProduct
        self.present(controller, animated: true)
    }
    
    @objc func goToCreator(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        controller.userId = duel?.idCreator
        self.present(controller, animated: true)
    }
    
    func initUI(){
        setProductUI()
        setCreatorUI()
        setDuration()
        
        productImage.layer.cornerRadius = 3
        userImage.layer.cornerRadius = userImage.frame.width / 2
        titleLabel.text = duel?.title
    }
    
    func setDuration(){
        guard let duration = duel?.duration else { return }
        let minutes = duration / 60
        let hours = duration / 3600
        let days = duration / (3600*24)
        
        var time = minutes
        var timeType = "min"
        
        if minutes >= 60 {
            time = hours
            timeType = "h"
        }
        if hours >= 24 {
            time = days
            timeType = "j"
        }
        
        self.timeLabel.text = "\"Je te donne \(time) \(timeType) pour ce défie !\""
    }
    
    func setProductUI(){
        guard let idProduct = duel?.idProduct else { return }
        db.collection("products").document(idProduct).getDocument { (snap, err) in
            guard let data = snap?.data() else { return }
            self.productNameLabel.text = data["name"] as? String
            self.produtBrandLabel.text = data["brand"] as? String
            self.productQuantityLabel.text = data["quantity"] as? String
            self.loadImage(url: data["image"] as? String, image: self.productImage)
        }
    }
    
    func setCreatorUI(){
        guard let idUser = duel?.idCreator else { return }
        db.collection("users").document(idUser).getDocument { (snap, err) in
            guard let data = snap?.data() else { return }
            
            self.usernameLabel.text = data["username"] as? String
            self.loadImage(url: data["image"] as? String, image: self.userImage)
        }
    }
    
    func loadImage(url : String?, image : UIImageView){
        guard let imgUrl = url else {
            NiceActivityIndicator().stopAnimating(image)
            return
        }
        
        image.downloaded(from: imgUrl, contentMode: .scaleAspectFill) {
            NiceActivityIndicator().stopAnimating(image)
        }
    }
    
    func wantToancelDuel(){
        guard let duelId = duel?.id else { return }
        let cancelDuelAction = UIAlertAction(title: "Oui", style: .default) { (action) in
            self.db.collection("duels").document(duelId).delete()
            self.dismiss(animated: true)
        }
        let noAction = UIAlertAction(title: "Non", style: .cancel)
        self.showAlert(title: "Etes-vous sûr de refuser le défi ?", message: "Attention, vous ne pourrez plus relever ce défi", actions: [cancelDuelAction,noAction])
    }
    
    @IBAction func onLaunchDuel(_ sender: Any) {
        guard let duelId = duel?.id, let duration = duel?.duration ,let userId = UserManager.shared.userId else { return }
        let launchDate = Timestamp(date: Date())
        let endDate = Timestamp(date: Date().addingTimeInterval(duration))
        db.collection("duels").document(duelId).updateData(["launchDate":launchDate,
                                                            "endDate":endDate,
                                                            "isPublic":false,
                                                            "idChallenger":userId])
        let ref = db.collection("duels").document(duelId)
        db.collection("users").document(userId).updateData(["duels": FieldValue.arrayUnion([ref])])
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onClose(_ sender: Any) {
        if duel?.isPublic == false {
            wantToancelDuel()
            return
        }
        self.dismiss(animated: true)
    }
    
}
