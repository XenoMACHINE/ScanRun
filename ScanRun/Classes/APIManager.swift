//
//  APIManager.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 13/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import Alamofire

class APIManager : NSObject {
    
    static let shared = APIManager()
    
    func getProduct(ean: String, callback : @escaping ([String:Any]) -> ()){
        let url = "https://europe-west1-scanruneu.cloudfunctions.net/api/getProduct/\(ean)"
        let headers : HTTPHeaders = ["Authorization":"Bearer \(UserManager.shared.token ?? "")"]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                callback(response.value as? [String:Any] ?? [:])
                break
                
            case .failure(let error):
                callback([:])
                print(error)
                break
            }
        }
    }
    
    func sendProduct(ean: String, name: String, brand: String?, quantity: String?, imageUrl: String?){
        let url = "https://europe-west1-scanruneu.cloudfunctions.net/api/sendProduct"
        let headers : HTTPHeaders = ["Authorization":"Bearer \(UserManager.shared.token ?? "")"]
        var parameters : Parameters = ["ean": ean, "name": name]
        
        if let noNilBrand = brand, noNilBrand != "" { parameters["brand"] = noNilBrand }
        if let noNilQuantity = quantity, noNilQuantity != "" { parameters["quantity"] = noNilQuantity }
        if let noNilImageUrl = imageUrl, noNilImageUrl != "" { parameters["imgUrl"] = noNilImageUrl }

        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                print(response.value ?? "")
                break
                
            case .failure(let error):
                if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8){
                    print("Server Error: " + str)
                }
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func sendNotif(userId : String, from username : String){
        let url = "https://europe-west1-scanruneu.cloudfunctions.net/api/sendNotif"
        let headers : HTTPHeaders = ["Authorization":"Bearer \(UserManager.shared.token ?? "")"]
        let parameters : Parameters = ["id": userId, "username": username]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                print(response.value ?? "")
                break
                
            case .failure(let error):
                if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8){
                    print("Server Error: " + str)
                }
                print(error.localizedDescription)
                break
            }
        }
    }
    
}
