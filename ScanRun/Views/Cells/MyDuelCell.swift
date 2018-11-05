//
//  MyDuelCell.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 05/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyDuelCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var imageDuel: UIImageView!
    
    lazy var db = Firestore.firestore()
    
    var tmpUrl : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageDuel.layer.cornerRadius = imageDuel.bounds.height / 2
        self.imageDuel.clipsToBounds = true
        self.imageDuel.layer.borderWidth = 2.0
        self.imageDuel.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImage(imageUrl : String?){
        guard tmpUrl != imageUrl else { return } //already loaded
        NiceActivityIndicatorBuilder().setType(.orbit).setColor(.white).build().startAnimating(self.imageDuel)
        guard let imgUrl = imageUrl else {
            NiceActivityIndicator().stopAnimating(self.imageDuel)
            return }
        tmpUrl = imgUrl
        self.imageDuel.downloaded(from: imgUrl, callback: {
            NiceActivityIndicator().stopAnimating(self.imageDuel)
        })
    }
}
