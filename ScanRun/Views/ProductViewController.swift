//
//  ProductViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 22/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProductViewController: UIViewController {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    var productId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getProduct()
    }
    
    func getProduct(){
        guard let idProduct = productId else { return }
        NiceActivityIndicatorBuilder().setType(.ballPulse).setColor(.white).build().startAnimating(self.productImage)
        
        db.collection("products").document(idProduct).getDocument { (snap, err) in
            if let snapshot = snap, let json = snapshot.data() {
                self.initUI(product: Product(json: json))
            }else {
                NiceActivityIndicator().stopAnimating(self.productImage)
            }
        }
    }
    
    func initUI(product : Product){
        self.loadImage(url: product.imageUrl)
        self.brandLabel.text = product.brand
        self.nameLabel.text = product.name ?? ""
        
        if let quantity = product.quantity, quantity != ""{
            self.quantityLabel.text = "Q. \(quantity)"
        }
    }
    
    func loadImage(url : String?){
        guard let imgUrl = url else {
            NiceActivityIndicator().stopAnimating(self.productImage)
            return
        }
        
        self.productImage.downloaded(from: imgUrl, contentMode: .scaleAspectFill) {
            if self.productImage.image == nil {
                self.productImage.image = UIImage(named: "placeholder")
            }
            NiceActivityIndicator().stopAnimating(self.productImage)
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
