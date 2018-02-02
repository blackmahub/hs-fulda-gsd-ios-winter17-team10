//
//  ViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, JSONDataDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let s2TGebPlan = S2TGebPlanService()
    let locationManager = CLLocationManager()
    
    var s2TGebPlans = [S2TGebPlan]()
    var isRegionDefined = false

    @IBOutlet weak var gebPlanCollectionView: UICollectionView!
    @IBOutlet weak var campusMap: MKMapView!
    
    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gebPlanCollectionView.delegate = self
        gebPlanCollectionView.dataSource = self
        
        s2TGebPlan.delegate = self
        
        campusMap.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = CLLocationDistance(1)
        locationManager.activityType = CLActivityType.otherNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return s2TGebPlans.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RaumScheduleCell", for: indexPath) as! RaumCollectionViewCell
        
        cell.raum.text = s2TGebPlans[indexPath.item].Raum
        cell.beginn.text = "\(s2TGebPlans[indexPath.item].Beginn)"
        cell.ende.text = "\(s2TGebPlans[indexPath.item].Ende)"
        cell.gruppe.text = s2TGebPlans[indexPath.item].Gruppe
        cell.lvaName.text = s2TGebPlans[indexPath.item].LvaName
        cell.dozent.text = s2TGebPlans[indexPath.item].Dozent
        
        return cell
    }
    
    func dataDidRecieved(data: [S2TGebPlan]) {
        
        DispatchQueue.main.async {
            
            self.s2TGebPlans = data
            self.gebPlanCollectionView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard !locations.isEmpty else {
            
            print("Locations Array is empty, no Location is found.")
            return
        }
        
        let currentLocation = locations.last!
        
        print("Current Location: \(currentLocation.description)")
        print("Current Location Coordinate: \(currentLocation.coordinate)")
        print("Current Location Latitude: \(currentLocation.coordinate.latitude.description)")
        print("Current Location Longitude: \(currentLocation.coordinate.longitude.description)")
        
        if !isRegionDefined {
            
            let locationDistance = CLLocationDistance(1000)
            let currentRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, locationDistance, locationDistance)
            campusMap.setRegion(currentRegion, animated: true)
            
            isRegionDefined = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Unable to get Current Location Data.")
        print("Error: \(error.localizedDescription)")
    }
    
    @IBAction func getGebPlanFromS2T(_ sender: UIButton) {
    
        s2TGebPlan.get(of: nil)
    }
    
}

