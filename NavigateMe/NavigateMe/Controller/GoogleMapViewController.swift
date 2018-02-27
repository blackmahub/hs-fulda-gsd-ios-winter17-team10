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

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate {

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
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = CLActivityType.otherNavigation
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.last!
        
        (self.view as! GMSMapView).animate(toLocation: currentLocation.coordinate)
        
        let origin = currentLocation.coordinate
        let destination = CLLocationCoordinate2D(latitude: 50.5551995, longitude: 9.6793356)
        self.getDirectionFromGoogleMapAPI(origin: origin, destination: destination)
    }
    
    func getDirectionFromGoogleMapAPI(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=AIzaSyA5WKLZCTreqWGGVNdeucTzqCgsLfEf8CU&mode=walking")!
        
        print("\nURL: \(url)\n")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            print("\nJSON Response from Google Direction API:\n")
            print("\(data)\n")
            
            guard let directionData = data else {
                return
            }
            
            DispatchQueue.main.async {
                
                do {
                    self.googleDirection = try JSONDecoder().decode(GoogleDirection.self, from: directionData)
                    print("After Decode: \(self.googleDirection)\n")
                } catch let jsonError {
                    print("\nJSON Error: " + jsonError.localizedDescription + "\n")
                }
                
                guard self.googleDirection != nil,
                    "OK" == self.googleDirection!.status else {
                        
                        return
                }
                
                print("\nCreating GMS Path ...\n")
                let steps = self.googleDirection!.routes.flatMap({ $0.legs.flatMap({ $0.steps }) })
                print("\nSteps: \(steps)\n")
                
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
        }.resume()
    }
    
}

struct GoogleDirection: Decodable {
    
    var routes: [GoogleRoute]
    var status: String
}

struct GoogleRoute: Decodable {
    
    var legs: [GoogleLeg]
    
}

struct GoogleLeg: Decodable {
    
    var steps: [GoogleStep]
    
}

struct GoogleStep: Decodable {
    
    var start_location: GoogleLocation
    var end_location: GoogleLocation
    
}

struct GoogleLocation: Decodable {
    
    var lat: Double
    var lng: Double
    
}
