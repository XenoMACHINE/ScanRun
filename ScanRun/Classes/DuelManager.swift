//
//  DuelManager.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 03/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DuelManager : NSObject {
    
    static let shared = DuelManager()
    private lazy var db = Firestore.firestore()

    
    func getPublicDuels(callback : @escaping (_ duels : [Duel]) -> ()) {
        
        db.collection("duels").whereField("isPublic", isEqualTo: true).addSnapshotListener({ (snapshot, error) in
            callback((snapshot?.documents ?? []).map({
                Duel(json: $0.data())
            }))
        })
        
    }
    
}
