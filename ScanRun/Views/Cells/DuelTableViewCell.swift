//
//  DuelTableViewCell.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 03/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class DuelTableViewCell: UITableViewCell {
    
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
        duelDuration.text = "\(duel.duration ?? 0)"
    }

}
