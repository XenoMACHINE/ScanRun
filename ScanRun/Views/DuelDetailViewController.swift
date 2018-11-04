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
        
        productImage.layer.cornerRadius = 3
        userImage.layer.cornerRadius = userImage.frame.width / 2
        titleLabel.text = duel?.title
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
    
    @IBAction func onLaunchDuel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
