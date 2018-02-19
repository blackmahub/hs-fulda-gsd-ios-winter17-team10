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
    
    var freeRaums = [String : [Int : [(raum: Int, duration: String)]]]()
    
    @IBOutlet weak var searchDateTime: UIDatePicker!
    @IBOutlet weak var gebCollectionView: UICollectionView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        app.delegate = self
        
        gebCollectionView.delegate = self
        gebCollectionView.dataSource = self
    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {

        print("\nDate Picker Date: " + searchDateTime.date.description + "\n")
        
        app.gebs = ["46(E)."]
        app.search = searchDateTime.date
        app.searchFreeRaums()
    }
    
    @IBAction func navigateMeInThisRaum(_ sender: UIButton) {
        
        let freeRaum = freeRaums["46(E)"]![1]!.filter({ $0.raum == Int(sender.currentTitle!) }).first!
        let title = "Raum: \(freeRaum.raum)"
        let message = "Free for next " + freeRaum.duration
        
        let navigationConfirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let navigateAction = UIAlertAction(title: "Navigate Me", style: .default) { alertAction in
            
            print("Hello, please navigate me to " + title + ".\n")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        navigationConfirmAlert.addAction(navigateAction)
        navigationConfirmAlert.addAction(cancelAction)
        
        self.present(navigationConfirmAlert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let floors = self.freeRaums["46(E)"] else {
            
            return 0
        }
        
//        return floors.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GebCell", for: indexPath) as! GebCollectionViewCell
        
        guard let floors = self.freeRaums["46(E)"] else {
            
            return cell
        }
        
//        for (index, floor) in floors.keys.enumerated() {
//
//            if indexPath.item == index {
//
//                cell.gebLabel.text = "Geb 46(E): Floor \(floor)"
//
//                cell.freeRaumLabel.text = floors[floor]!.reduce("", { (result, raum) in
//
//                    return result + raum + "\n"
//                })
//
//                break
//            }
//        }
        
        var freeRaumsOfFloor1 = [Int]()
        
        for floor in floors {
            
            if 1 == floor.key {
                
                freeRaumsOfFloor1 = floor.value.map({ $0.raum })
                break
            }
        }
        
        print("\nFree Raums Array from Free Raums Dictionary:\n")
        print("\(freeRaumsOfFloor1)\n")
        
        cell.gebLabel.text = "Geb 46(E): Floor 1"
        
        
        let floorPlan = ImageProcessor.processImage(floor: 1, freeRaums: freeRaumsOfFloor1, imageViewFrame: cell.floorPlanView.frame, parentViewFrames: cell.frame, collectionView.frame)
        
        cell.floorPlanView.image = UIImage(ciImage: floorPlan.image)
        
        for buttonFrame in floorPlan.buttonFrames {
            
            let raumButton = UIButton(frame: buttonFrame.value)
            
            raumButton.backgroundColor = UIColor.green
            raumButton.setTitle("\(buttonFrame.key)", for: .normal)
            raumButton.titleLabel!.font = raumButton.titleLabel!.font.withSize(CGFloat(30))
            raumButton.setTitleColor(UIColor.black, for: .normal)
            raumButton.addTarget(self, action: #selector(ViewController.navigateMeInThisRaum(_:)), for: .touchUpInside)
            
            self.view.addSubview(raumButton)
        }
        
        return cell
    }
    
    func processDidComplete(then dto: [FreeRaumDTO]) {
        
        // reset free raums dictionary
        self.freeRaums = [String : [Int : [(raum: Int, duration: String)]]]()
        
        DispatchQueue.main.async {
            
            print("Free Raums Count: \(dto.count)\n")
            
            dto.forEach { freeRaum in
             
                print("Geb: " + freeRaum.geb)
                print("Floor: \(freeRaum.floor)")
                print("Raum: \(freeRaum.raum)")
                print("Duration: \(freeRaum.duration)\n")
                
                if !self.freeRaums.keys.contains(freeRaum.geb) {
                    
                    self.freeRaums[freeRaum.geb] = [Int : [(raum: Int, duration: String)]]()
                }
                    
                if !self.freeRaums[freeRaum.geb]!.keys.contains(freeRaum.floor) {
                
                    self.freeRaums[freeRaum.geb]![freeRaum.floor] = [(raum: Int, duration: String)]()
                }
                
                self.freeRaums[freeRaum.geb]![freeRaum.floor]! += [(freeRaum.raum, freeRaum.duration)]
            }
            
            print("Free Raums Dictionary:")
            print(self.freeRaums.description)
            
            self.gebCollectionView.isHidden = false
            self.gebCollectionView.reloadData()
        }
    }
    
    func processDidAbort(reason message: String) {
        
        DispatchQueue.main.async {
            
            print("Process is aborted.")
            print("Reason: " + message)
            
            self.gebCollectionView.isHidden = true
            
            let abortAlert = UIAlertController(title: "Process is aborted.", message: "Reason: " + message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            abortAlert.addAction(cancelAction)
            self.present(abortAlert, animated: true)
        }
    }
    
}
