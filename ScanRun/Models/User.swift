//
//  User.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 07/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class User: NSObject {

    var username : String?
    var id : String?
    var email : String?
    var score : Int = 0
    
    init(id : String?, email: String?) {
        self.email = email
        self.id = id
    }
    
    init(json : [String:Any]){
        self.username = json["username"] as? String
        self.id = json["id"] as? String
        self.email = json["email"] as? String
        self.score = json["score"] as? Int ?? 0
    }
}
