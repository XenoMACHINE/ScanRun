//
//  DuelTableViewCell.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 03/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DuelTableViewCell: UITableViewCell {
    
    lazy var db = Firestore.firestore()
    @IBOutlet weak var duelMedia: UIImageView!
    @IBOutlet weak var duelTitle: UILabel!
    @IBOutlet weak var duelDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.duelMedia.layer.cornerRadius = duelMedia.bounds.height / 2
        self.duelMedia.clipsToBounds = true
        self.duelMedia.layer.borderWidth = 2.0
        self.duelMedia.layer.borderColor = UIColor.white.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setup(duel : Duel) {
        duelTitle.text = duel.title
        
        setDuration(duration: duel.duration ?? 0)
        if let idProduct = duel.idProduct{
            setImage(idProduct: idProduct)
        }
    }
    
    func setDuration(duration : Double){
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
        
        duelDuration.text = "\(time.clean) \(timeType)"
    }
    
    func setImage(idProduct : String){
        NiceActivityIndicatorBuilder().setType(.orbit).setColor(.white).build().startAnimating(self.duelMedia)
        db.collection("products").document(idProduct).getDocument { (snap, err) in
            guard let data = snap?.data() else {
                NiceActivityIndicator().stopAnimating(self.duelMedia)
                return }
            let product = Product(json: data)
            guard let imgUrl = product.imageUrl else {
                NiceActivityIndicator().stopAnimating(self.duelMedia)
                return }
            
            self.duelMedia.downloaded(from: imgUrl, callback: {
                NiceActivityIndicator().stopAnimating(self.duelMedia)
            })
        }
    }

}
