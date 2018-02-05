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

class ViewController: UIViewController, UICollectionViewDelegate, /*UICollectionViewDataSource,*/ RESTServiceDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let s2TGebPlan = S2TGebPlanService()
    let locationManager = CLLocationManager()
    
    var s2TGebPlans = [S2TGebPlan]()
    var isRegionDefined = false

//    @IBOutlet weak var gebPlanCollectionView: UICollectionView!
//    @IBOutlet weak var campusMap: MKMapView!
    @IBOutlet weak var searchDateTime: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        gebPlanCollectionView.delegate = self
//        gebPlanCollectionView.dataSource = self
        
        s2TGebPlan.delegate = self
        
        s2TGebPlan.get(of: nil, on: Date())
        
//        campusMap.delegate = self
        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = CLLocationDistance(1)
//        locationManager.activityType = CLActivityType.otherNavigation
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = true
//        locationManager.startUpdatingLocation()
    }

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return s2TGebPlans.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RaumScheduleCell", for: indexPath) as! RaumCollectionViewCell
//
//        cell.raum.text = s2TGebPlans[indexPath.item].Raum
//        cell.beginn.text = "\(s2TGebPlans[indexPath.item].Beginn)"
//        cell.ende.text = "\(s2TGebPlans[indexPath.item].Ende)"
//        cell.gruppe.text = s2TGebPlans[indexPath.item].Gruppe
//        cell.lvaName.text = s2TGebPlans[indexPath.item].LvaName
//        cell.dozent.text = s2TGebPlans[indexPath.item].Dozent
//
//        return cell
//    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {
        
        print("Date Picker Calendar: " + searchDateTime.calendar.description)
        print("Date Picker Date: " + searchDateTime.date.description)
        print()
        
        print(Utils.onlyDateEqual(searchDateTime.date, to: Date()))
    }
    
    func dataDidReceive(data: [S2TGebPlan]) {
        
        DispatchQueue.main.async {
            
            self.s2TGebPlans = data
            
            print("Total Records: \(self.s2TGebPlans.count)")
            
            for plan in self.s2TGebPlans {
                
                let beginnInSeconds = Double(plan.Beginn) / 1000.0
                let endeInSeconds = Double(plan.Ende) / 1000.0
                
                let beginnDateTime = Date(timeIntervalSince1970: beginnInSeconds)
                let endeDateTime = Date(timeIntervalSince1970: endeInSeconds)
                
                print("Buildling and Raum: " + plan.Raum)
                print("Beginn: " + beginnDateTime.description)
                print("Ende: " + endeDateTime.description)
                print("Gruppe: " + plan.Gruppe)
                print()
            }
            
//            self.gebPlanCollectionView.reloadData()
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard !locations.isEmpty else {
//
//            print("Locations Array is empty, no Location is found.")
//            return
//        }
//
//        let currentLocation = locations.last!
//
//        print("Current Location: \(currentLocation.description)")
//        print("Current Location Coordinate: \(currentLocation.coordinate)")
//        print("Current Location Latitude: \(currentLocation.coordinate.latitude.description)")
//        print("Current Location Longitude: \(currentLocation.coordinate.longitude.description)")
//
//        if !isRegionDefined {
//
//            let locationDistance = CLLocationDistance(1000)
//            let currentRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, locationDistance, locationDistance)
//            campusMap.setRegion(currentRegion, animated: true)
//
//            isRegionDefined = true
//        }
//
//        campusMap.showsUserLocation = true
//        campusMap.showsCompass = true
//        campusMap.showsScale = true
//        campusMap.showsTraffic = true
//        campusMap.showsBuildings = true
//        campusMap.showsPointsOfInterest = true
//    }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//
//        print("Unable to get Current Location Data.")
//        print("Error: \(error.localizedDescription)")
//    }
    
//    @IBAction func getGebPlanFromS2T(_ sender: UIButton) {
//
//        s2TGebPlan.get(of: nil)
//    }
    
}
