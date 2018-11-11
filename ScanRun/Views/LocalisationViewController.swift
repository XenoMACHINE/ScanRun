//
//  LocalisationViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 10/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import CoreLocation
import  FirebaseFirestore

class LocalisationViewController: UIViewController {

    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var enseigneNameTf: UITextField!
    @IBOutlet weak var validBtn: GlobalButton!
    
    lazy var db = Firestore.firestore()
    
    let locationManager = CLLocationManager()
    var coordonates : GeoPoint?
    
    var duel : Duel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Localisation"
        locate()
        pointView.layer.cornerRadius = pointView.frame.width / 2
        enseigneNameTf.delegate = self
    }
    
    func locate(){
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func canValid(){
        validBtn.alpha = 0.5
        validBtn.isEnabled = false
        if coordonates != nil {//&& (enseigneNameTf.text?.count ?? 0 > 0){
            validBtn.alpha = 1
            validBtn.isEnabled = true
        }
    }
    
    func addSearchAnimation(){
        let radius = pointView.bounds.size.width/2.0
        
        let count = 4
        let duration : Double = 7
        
        for i in 0..<count{
            let circle = UIView(frame: pointView.bounds)
            circle.layer.cornerRadius = radius
            circle.layer.borderWidth = 0.1
            circle.layer.borderColor = UIColor.white.cgColor
            circle.backgroundColor = UIColor.clear
            circle.layer.masksToBounds = true
            
            
            pointView.addSubview(circle)
            
            circle.alpha = 0.3
            circle.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            let delay = Double(i)*duration/Double(count)
            UIView.animate(withDuration: duration, delay: delay, options: .repeat, animations: {
                circle.transform = CGAffineTransform(scaleX: 40, y: 40)
                circle.alpha = 0
            })
        }
    }
    
    @IBAction func onValid(_ sender: Any) {
        guard let idProduct = duel?.idProduct, let geoPoint = coordonates, let duelId = duel?.id else { return }
        db.collection("products").document(idProduct).updateData(["geoPoints": FieldValue.arrayUnion([geoPoint])])
        db.collection("duels").document(duelId).updateData(["succeed" : true])
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension LocalisationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.canValid()
        return true
    }
}

extension LocalisationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.coordonates = GeoPoint(latitude: locValue.latitude, longitude: locValue.longitude)
        self.canValid()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            self.dismiss(animated: true)
        case .restricted:
            self.dismiss(animated: true)
        case .denied:
            self.dismiss(animated: true)
        case .authorizedAlways:
            self.addSearchAnimation()
        case .authorizedWhenInUse:
            self.addSearchAnimation()
        }
    }
}
