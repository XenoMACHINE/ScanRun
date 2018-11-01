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

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, callback : @escaping () -> ()) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    callback()
                    return
                }
            DispatchQueue.main.async() {
                self.image = image
                callback()
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, callback : @escaping () -> ()) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: contentMode) {
            callback()
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
