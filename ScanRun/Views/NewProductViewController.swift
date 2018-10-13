//
//  NewProductViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 13/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class NewProductViewController: UIViewController {
    
    @IBOutlet weak var eanCodeTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var brandTf: UITextField!
    @IBOutlet weak var quantityTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayError(){
        self.showAlert(title: "Veuillez remplir les champs", message: "Le code barre et le nom du produit sont obligatoire")
    }
    
    @IBAction func onImage(_ sender: Any) {
        //TODO
    }
    
    @IBAction func onScan(_ sender: Any) {
        //TODO
    }
    
    @IBAction func onSend(_ sender: Any) {
        guard let eanCode = eanCodeTf.text, eanCode != "", let name = nameTf.text, name != "" else {
            displayError()
            return
        }
        
        APIManager.shared.sendProduct(ean: eanCode, name: name, brand: brandTf.text, quantity: quantityTf.text, imageUrl: nil)
        self.dismiss(animated: true)
    }
}
