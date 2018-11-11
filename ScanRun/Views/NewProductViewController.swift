//
//  NewProductViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 13/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseStorage

class NewProductViewController: UIViewController {
    
    @IBOutlet weak var stackTextfield: UIStackView!
    @IBOutlet weak var eanCodeTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var brandTf: UITextField!
    @IBOutlet weak var quantityTf: UITextField!
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var sendButton: GlobalButton!
    
    var passedEAN = ""
    var imagePicker: UIImagePickerController!
    var imageURL : String?
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicked.contentMode = UIViewContentMode.scaleAspectFit
        imagePicked.layer.borderWidth = 1
        imagePicked.layer.borderColor = UIColor.white.cgColor
        
        self.nameTf.becomeFirstResponder()
        
        if passedEAN != "" {
            self.eanCodeTf.text = passedEAN
        }
        
        addDelegateTextfieldsInStackview()
    }
    
    func uploadImageToStorage() {
        sendButton.setAnimating(animated: true)
        if let imageToSave = imagePicked.image,
            let data = UIImageJPEGRepresentation(imageToSave, 1.0) {
            
            let imagesRef = self.storageRef.child("images/\(self.passedEAN).jpg")
            imagesRef.putData(data, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.getURL()
            }
        }
    }
    
    func getURL() {
        storageRef.child("images/\(self.passedEAN).jpg").downloadURL { (url, error) in
            if let error = error {
                print(error)
            }
            self.imageURL = url?.absoluteString
            self.sendButton.setAnimating(animated: false)
        }
    }
    
    func displayError(){
        self.showAlert(title: "Veuillez remplir les champs", message: "Le code barre et le nom du produit sont obligatoire")
    }
    
    func addDelegateTextfieldsInStackview() {
        var count = 0
        for view in stackTextfield.subviews{
            if let textfield = view as? UITextField{
                textfield.delegate = self
                textfield.tag = count
                count += 1
            }
        }
    }
    
    @IBAction func onImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        }
    }
    
    @IBAction func onSend(_ sender: Any) {
        guard let eanCode = eanCodeTf.text, eanCode != "", let name = nameTf.text, name != "" else {
            displayError()
            return
        }
        
        APIManager.shared.sendProduct(ean: eanCode, name: name, brand: brandTf.text, quantity: quantityTf.text, imageUrl: self.imageURL)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension NewProductViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag + 1 < stackTextfield.subviews.count,
            let mTextField = stackTextfield.subviews[textField.tag + 1] as? UITextField,
            mTextField.isHidden == false{
            
            mTextField.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
    
}

extension NewProductViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true)
        imagePicked.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        uploadImageToStorage()
    }
    
}
