//
//  MenuTableViewCell.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 02/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var media: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func setup(data: (menuData: MenuData, image: UIImage)) {
        self.title.text = data.menuData.rawValue
        self.media.image = data.image
    }

}
