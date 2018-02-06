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
    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {
        
        print("Date Picker Date: " + searchDateTime.date.description + "\n")
        
        app.search = searchDateTime.date
        app.searchFreeRaums()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.freeRaums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GebCell", for: indexPath) as! GebCollectionViewCell
        
        for (index, geb) in self.freeRaums.keys.enumerated() {
            
            if indexPath.item == index {
                
                cell.gebLabel.text = geb
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
        }
    }
    
    func processDidAbort(reason message: String) {
        
        print("Process is aborted.")
        print("Reason: " + message)
    }
    
}
