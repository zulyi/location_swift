//
//  ViewController.swift
//  taxi_map_test
//
//  Created by Anton on 7/20/19.
//  Copyright © 2019 Moto-Life. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var adress: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.startLocationUpates()
        }
    }
    
    func startLocationUpates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = locations.first else {
            return
        }
        self.displayLocation(location: locations.first!)
    }
 
    
    func displayLocation(location:CLLocation){
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) , span: MKCoordinateSpan(latitudeDelta: 0.05 ,longitudeDelta: 0.05)), animated: true)
        let locationPinCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoordinate
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        
        self.loadAddress(location: location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status !=  CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted{
            self.startLocationUpates()
        }
    }
    
    func loadAddress(location:CLLocation){
        let session = URLSession.shared
        let url = URL(string: "https://nominatim.openstreetmap.org/reverse.php?format=json&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)")!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            
            if let response = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: response, options: []) as! [String:Any]
                    DispatchQueue.main.async {
                        self.adress.text = json["display_name"] as? String
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }
        })
        task.resume()
    }
}

