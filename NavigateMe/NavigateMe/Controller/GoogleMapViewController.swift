//
//  GoogleMapViewController.swift
//  NavigateMe
//
//  Created by mahbub on 2/26/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, EngineDelegate {

    let navigation = NEngine()
    
    let universityCampusArea = CLLocationCoordinate2D(latitude: 50.5650077, longitude: 9.6853589)
    let centerLocationGeb46E = CLLocationCoordinate2D(latitude: 50.5650899, longitude: 9.6855439)
    let locationManager = CLLocationManager()
    
    var geb: String? = nil
    var floor: Int? = nil
    var raum: Int? = nil
    var duration: String? = nil
    var googleDirection: GoogleDirection? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let cameraPostion = GMSCameraPosition.camera(withLatitude: self.universityCampusArea.latitude, longitude: universityCampusArea.longitude, zoom: 20) // 18
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: cameraPostion)
        mapView.isMyLocationEnabled = true
        
        let groundOverlay = GMSGroundOverlay(position: centerLocationGeb46E, icon: UIImage(named: "E\(self.floor!).png"), zoomLevel: CGFloat(19.7))
        groundOverlay.bearing = 30
        groundOverlay.map = mapView
        
        self.view = mapView
        
        self.navigation.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = CLActivityType.otherNavigation
        self.locationManager.distanceFilter = 100
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.last!
        
        (self.view as! GMSMapView).animate(toLocation: currentLocation.coordinate)
        
        let origin = currentLocation.coordinate
        let destination = CLLocationCoordinate2D(latitude: 50.5551995, longitude: 9.6793356)
        self.navigation.getDirectionFromGoogleMapAPI(origin: origin, destination: destination)
    }
    
    func processDidComplete(then dto: Any) {
        
        let steps = dto as! [GoogleStep]
        
        DispatchQueue.main.async {
            
            let path = GMSMutablePath()
            
            steps.forEach { step in
                
                path.add(CLLocationCoordinate2D(latitude: step.start_location.lat, longitude: step.start_location.lng))
                path.add(CLLocationCoordinate2D(latitude: step.end_location.lat, longitude: step.end_location.lng))
            }
            
            // inside university path
            path.add(CLLocationCoordinate2D(latitude: 50.5649110, longitude: 9.6860784))
            path.add(CLLocationCoordinate2D(latitude: 50.5649485, longitude: 9.6859888))
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5
            polyline.strokeColor = UIColor.purple
            polyline.map = self.view as! GMSMapView
        }
    }
    
    func processDidAbort(reason message: String) {
        
        DispatchQueue.main.async {
            
            let abortAlert = UIAlertController(title: "Process is aborted.", message: "Reason: " + message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { alertAction in
                
                // TODO - Back to existing FreeRaumViewController instance
            }
            abortAlert.addAction(cancelAction)
            self.present(abortAlert, animated: true)
        }
    }
    
}
