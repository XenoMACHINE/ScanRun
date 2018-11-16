//
//  ProductLocationViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 16/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore

class ProductLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var product : Product!
    var currentIndex = 0
    var annotationByGeoloc : [GeoPoint:MKAnnotation] = [:]
    var canSelect = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.mapType = .hybrid
        mapView.delegate = self
        
        addAnnotations()
        zoomOnPoint()
    }
    
    func addAnnotations(){
        for geoPoint in product.geoPoints{
            let CLLCoordType = CLLocationCoordinate2D(latitude: geoPoint.latitude,
                                                      longitude: geoPoint.longitude);
            let anno = MKPointAnnotation()
            anno.coordinate = CLLCoordType
            anno.title = "\(product.name ?? "")"
            mapView.addAnnotation(anno)
            annotationByGeoloc[geoPoint] = anno
        }
    }
    
    func zoomOnPoint(){
        if currentIndex >= product.geoPoints.count {
            currentIndex = 0
        }
        
        let geopoint = product.geoPoints[currentIndex]
        let latitude:CLLocationDegrees = geopoint.latitude
        let longitude:CLLocationDegrees = geopoint.longitude
        
        let latDelta:CLLocationDegrees = 0.011
        let lonDelta:CLLocationDegrees = 0.011
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: false)
        
        if let annotation = annotationByGeoloc[geopoint]{
            canSelect = false
            mapView.selectAnnotation(annotation, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mapView.deselectAnnotation(annotation, animated: true)
                self.canSelect = true
            }
        }
        
        currentIndex += 1
    }
    
    func openMapForPlace(lat: Double, long: Double) {

        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long
        
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(product.name ?? "")"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func onNext(_ sender: Any) {
        zoomOnPoint()
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ProductLocationViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard canSelect, let coordinate = view.annotation?.coordinate else { return }
        openMapForPlace(lat: coordinate.latitude, long: coordinate.longitude)
    }
}
