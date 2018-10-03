//
//  UserManager.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 05/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore

class UserManager: NSObject {

    static let shared = UserManager()
    
    lazy var db = Firestore.firestore()

    var token : String?
    var userId : String?
    var email : String {
        get{
            return UserDefaults.standard.string(forKey: "user_email") ?? ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "user_email")
        }
    }
    
    func setToken(){
        self.userId = Auth.auth().currentUser?.uid
        self.pushFCMToken()
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            self.token = token
        })
    }
    
    func pushFCMToken(){
        if let usrId = self.userId, let token = Messaging.messaging().fcmToken{
            self.db.collection("users").document(usrId).updateData(["FCMToken":token])
        }
    }
}
