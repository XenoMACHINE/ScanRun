//
//  Duel.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 03/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class Duel: NSObject {
    
    var title : String?
    var id : String?
    var isClosed : Bool?
    var idProduct : String?
    var isPublic : Bool?
    var duration : Double?
    
    init(title : String?, id : String?, isClosed : Bool? = false, idProduct : String?, isPublic : Bool?, duration : Double?) {
        self.title = title
        self.id = id
        self.isClosed = isClosed
        self.idProduct = idProduct
        self.isPublic = isPublic
        self.duration = duration
    }
    
    init(json : [String:Any]) {
        self.title = json["title"] as? String
        self.id = json["id"] as? String
        self.isClosed = json["isClosed"] as? Bool
        self.idProduct = json["idProduct"] as? String
        self.isPublic = json["isPublic"] as? Bool
        self.duration = json["duration"] as? Double
    }
}
