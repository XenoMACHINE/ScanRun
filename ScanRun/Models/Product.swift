//
//  Product.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 22/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class Product: NSObject {
    
    var id : String?
    var brand : String?
    var imageUrl : String?
    var name : String?
    var quantity : String?
    var loadedImage : UIImage?
    var geoPoints : [GeoPoint] = []
    
    init(json: [String:Any]){
        self.id = json["id"] as? String
        self.brand = json["brand"] as? String
        self.imageUrl = json["image"] as? String
        self.name = json["name"] as? String
        self.quantity = json["quantity"] as? String
        
        for geoPoint in json["geoPoints"] as? [[String:Any]] ?? []{
            guard let latitude = geoPoint["_latitude"] as? Double,  let longitude = geoPoint["_longitude"] as? Double else { return }
            geoPoints.append(GeoPoint(latitude: latitude, longitude: longitude))
        }
    }
}
