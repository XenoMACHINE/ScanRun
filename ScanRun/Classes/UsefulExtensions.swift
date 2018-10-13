//
//  UsefulExtensions.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 13/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title : String, message : String, actions : [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel) { (_) in }], style : UIAlertControllerStyle = .actionSheet){
        
        var alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        if UIDevice().model == "iPad" {
            alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        }
        
        for action in actions{
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
