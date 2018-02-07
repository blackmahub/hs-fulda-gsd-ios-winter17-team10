//
//  ViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, AppEngineDelegate {
    
    let app = AppEngine()
    
    var freeRaums = [String : [Int : [String]]]()
    
    @IBOutlet weak var searchDateTime: UIDatePicker!
    @IBOutlet weak var abortMessageLabel: UILabel!
    @IBOutlet weak var gebCollectionView: UICollectionView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        app.delegate = self
        
        gebCollectionView.delegate = self
        gebCollectionView.dataSource = self
    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {
        
        print("Date Picker Date: " + searchDateTime.date.description + "\n")
        
        app.search = searchDateTime.date
        app.searchFreeRaums()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let floors = self.freeRaums["46(E)"] else {
            
            return 0
        }
        
        return floors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GebCell", for: indexPath) as! GebCollectionViewCell
        
        guard let floors = self.freeRaums["46(E)"] else {
            
            return cell
        }
        
        for (index, floor) in floors.keys.enumerated() {
            
            if indexPath.item == index {
                
                cell.gebLabel.text = "Geb 46(E): Floor \(floor)"
                
                cell.freeRaumLabel.text = floors[floor]!.reduce("", { (result, raum) in
                    
                    return result + raum + "\n"
                })
                
                break
            }
        }
        
        return cell
    }
    
    func processDidComplete(then dto: [FreeRaumDTO]) {
        
        DispatchQueue.main.async {
            
            print("Free Raums Count: \(dto.count)\n")
            
            dto.forEach { freeRaum in
             
                print("Geb: " + freeRaum.geb)
                print("Floor: \(freeRaum.floor)")
                print("Raum: \(freeRaum.raum)")
                print("Duration: \(freeRaum.duration)\n")
                
                if !self.freeRaums.keys.contains(freeRaum.geb) {
                    
                    self.freeRaums[freeRaum.geb] = [Int : [String]]()
                }
                    
                if !self.freeRaums[freeRaum.geb]!.keys.contains(freeRaum.floor) {
                    
                    self.freeRaums[freeRaum.geb]!.updateValue([String](), forKey: freeRaum.floor)
                }
                
                self.freeRaums[freeRaum.geb]![freeRaum.floor] = self.freeRaums[freeRaum.geb]![freeRaum.floor]! + ["Raum: \(freeRaum.raum) for next " + freeRaum.duration]
            }
            
            print("Free Raums Dictionary:")
            print(self.freeRaums.description)
        
            self.abortMessageLabel.isHidden = true
            
            self.gebCollectionView.isHidden = false
            self.gebCollectionView.reloadData()
        }
    }
    
    func processDidAbort(reason message: String) {
        
        DispatchQueue.main.async {
            
            print("Process is aborted.")
            print("Reason: " + message)
            
            self.gebCollectionView.isHidden = true
            
            self.abortMessageLabel.isHidden = false
            self.abortMessageLabel.text = "Process is aborted.\nReason: " + message
        }
    }
    
}
