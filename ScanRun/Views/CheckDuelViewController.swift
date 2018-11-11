//
//  CheckDuelViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 06/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class CheckDuelViewController: UIViewController {

    @IBOutlet weak var verifiedImg: UIImageView!
    @IBOutlet weak var endDuelBtn: GlobalButton!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productBrandLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productEanLabel: UILabel!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    var product : Product?
    var duel : Duel?
    
    var productScanned : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = duel?.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setProductUI()
        
        self.setTimeLeft()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.setTimeLeft()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkVerified()
    }
    
    func checkVerified(){
        guard productScanned != nil else { return }
        verifiedImg.isHidden = false
        if productScanned?.id == product?.id{
            verifiedImg.image = UIImage(named: "verified")
            endDuelBtn.isEnabled = true
            endDuelBtn.alpha = 1
        }else{
            verifiedImg.image = UIImage(named: "error")
        }
    }
    
    func setProductUI(){
        productImage.image = product?.loadedImage
        productNameLabel.text = product?.name
        productBrandLabel.text = product?.brand
        productQuantityLabel.text = product?.quantity
        productEanLabel.text = product?.id
    }
    
    func setTimeLeft(){
        timeLeftLabel.font = UIFont(name: "Bodoni 72 Oldstyle", size: 40)
        
        if let endDate = duel?.endDate?.dateValue(){
            let calendar = Calendar.current
            let timeLeft = calendar.dateComponents([.day,.hour,.minute,.second], from: Date(), to: endDate)
            
            let strDays = (timeLeft.day ?? 0) > 0 ? "\((timeLeft.day ?? 0))j " : ""
            let strHours = (timeLeft.hour ?? 0) > 0 ? "\((timeLeft.hour ?? 0))h " : ""
            let strMinutes = (timeLeft.minute ?? 0) > 0 ? "\((timeLeft.minute ?? 0))min " : ""
            let strSeconds = (timeLeft.second ?? 0) > 0 ? "\((timeLeft.second ?? 0))s " : ""
            
            timeLeftLabel.text = strDays + strHours + strMinutes + strSeconds
            if timeLeftLabel.text == "" {
                timeLeftLabel.text = "FINI"
            }
        }
    }
    
    @IBAction func onVerified(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "scan") as! ScanViewController
        self.present(controller, animated: true)
    }
    
    @IBAction func onEndDuel(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "LocalisationViewController") as! LocalisationViewController
        controller.duel = self.duel
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
