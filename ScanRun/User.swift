//
//  User.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 07/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class User: NSObject {

    var name : String?
    var id : String?
    var email : String?
    
    init(id : String?, email: String?) {
        self.email = email
        self.id = id
    }
}
