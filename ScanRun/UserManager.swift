//
//  UserManager.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 05/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserManager: NSObject {

    static let shared = UserManager()
    
    var token : String?
    
    func setToken(){
        
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            self.token = token
        })
    }
}
