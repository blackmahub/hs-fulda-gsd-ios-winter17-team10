//
//  ViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, JSONDataDelegate {
    
    let s2TGebPlan = S2TGebPlanService()
    var s2TGebPlans = [S2TGebPlan]()

    @IBOutlet weak var gebPlanCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gebPlanCollectionView.delegate = self
        gebPlanCollectionView.dataSource = self
        
        s2TGebPlan.delegate = self
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
    
    @IBAction func getGebPlanFromS2T(_ sender: UIButton) {
    
        s2TGebPlan.get(of: nil)
    }
    
}

