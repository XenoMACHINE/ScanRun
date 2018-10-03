//
//  GlobalButton.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 06/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class GlobalButton: UIButton {

    var activityIndicator: NVActivityIndicatorView!
    var tmpText : String?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.height / 10
        
        if activityIndicator == nil {
            activityIndicator = createActivityIndicator()
            self.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            self.addConstraints([horizontalConstraint, verticalConstraint])
        }
    }

    func setAnimating(animated : Bool){
        if animated{
            self.isEnabled = false
            tmpText = self.titleLabel?.text
            self.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        }else{
            self.isEnabled = true
            self.setTitle(tmpText, for: .normal)
            activityIndicator.stopAnimating()
        }
    }
    
    private func createActivityIndicator() -> NVActivityIndicatorView{
        let size : CGFloat = self.frame.height / 1.5
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        return NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulse, color: UIColor.white, padding: 0)
    }
}
