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
    
    let floors = ["Floor: 0" : 0, "Floor: 1" : 1, "Floor: 3" : 3]
    let raumCoordinates = ["46(E).0.9" : CLLocationCoordinate2D(latitude: 50.5652765, longitude: 9.6851969), "46(E).0.12" : CLLocationCoordinate2D(latitude: 50.5651926, longitude: 9.6854397)]
    
    let universityCampusArea = CLLocationCoordinate2D(latitude: 50.5650077, longitude: 9.6853589)
    let centerCoordinateGeb46E = CLLocationCoordinate2D(latitude: 50.5650899, longitude: 9.6855439)
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
        
        let groundOverlay = GMSGroundOverlay(position: self.centerCoordinateGeb46E, icon: UIImage(named: "E\(self.floor!).png"), zoomLevel: CGFloat(19.7))
        groundOverlay.bearing = 30
        groundOverlay.map = mapView
        
        self.view = mapView
        
        let floorSwitcher = UISegmentedControl(items: floors.keys.sorted())
        floorSwitcher.selectedSegmentIndex = self.floor!
        floorSwitcher.autoresizingMask = .flexibleWidth
        floorSwitcher.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        floorSwitcher.addTarget(self, action: #selector(GoogleMapViewController.drawFloorPlanOnMap(_:)), for: .valueChanged)
        self.navigationItem.titleView = floorSwitcher
        
        self.navigation.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = CLActivityType.otherNavigation
        self.locationManager.distanceFilter = 100
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func drawFloorPlanOnMap(_ sender: UISegmentedControl) {
        
        let mapView = self.view as! GMSMapView
        let currentFloor = self.floors[sender.titleForSegment(at: sender.selectedSegmentIndex)!]!
        
        let groundOverlay = GMSGroundOverlay(position: self.centerCoordinateGeb46E, icon: UIImage(named: "E\(currentFloor).png"), zoomLevel: CGFloat(19.7))
        groundOverlay.bearing = 30
        groundOverlay.zIndex = 0
        groundOverlay.map = mapView
        
        mapView.animate(toLocation: self.centerCoordinateGeb46E)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.last!
        
        (self.view as! GMSMapView).animate(toLocation: currentLocation.coordinate)
        
        let origin = currentLocation.coordinate
        let destination = CLLocationCoordinate2D(latitude: 50.5639708, longitude: 9.6852563)
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
//            path.add(CLLocationCoordinate2D(latitude: 50.5649485, longitude: 9.6859888))
            path.add(CLLocationCoordinate2D(latitude: 50.5648966, longitude: 9.6860720))
            path.add(CLLocationCoordinate2D(latitude: 50.5649281, longitude: 9.6859788))
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5
            polyline.strokeColor = UIColor.purple
            polyline.zIndex = 100
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
