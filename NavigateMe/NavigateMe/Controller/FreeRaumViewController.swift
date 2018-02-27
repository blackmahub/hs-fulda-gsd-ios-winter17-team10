//
//  FreeRaumViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit

class FreeRaumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, EngineDelegate {
    
    let app = CAEngine()
    
    var freeRaums = [String : [Int : [(raum: Int, duration: String)]]]()
    var freeRaumButtons = [Int : [UIButton]]()
    
    @IBOutlet weak var searchDateTime: UIDatePicker!
    @IBOutlet weak var gebCollectionView: UICollectionView!

    override func viewDidLoad() {

        super.viewDidLoad()
        
        app.delegate = self
        
        gebCollectionView.delegate = self
        gebCollectionView.dataSource = self

        // doing one time image processing for entire application life cycle
        guard IPEngine.floorPlans.isEmpty else {
            
            return
        }
        
        self.startImageProcessor()
    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {

//        print("\nDate Picker Date: " + searchDateTime.date.description + "\n")
        
        app.gebs = ["46(E)."]
        app.search = searchDateTime.date
        app.searchFreeRaums()
    }
    
    @IBAction func navigateMeInThisRaum(_ sender: UIButton) {
        
        let raum = Int(sender.currentTitle!)!
        let floorTag = sender.tag - raum
        
        for geb in self.freeRaums {
            
            let gebNummerMitLetter = geb.key.utf8.reduce(0, { result, codeUnit in result + Int(codeUnit) })
            let floor = geb.value.filter({ floorTag  == (gebNummerMitLetter + $0.key) })
            
            guard !floor.isEmpty else {
                continue
            }
            
            let freeRaum = floor.first!.value.filter({ raum == $0.raum }).first!
            self.generateNavigationConfirmAlert(for: (geb.key, floor.first!.key, freeRaum.raum, freeRaum.duration))
            
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let floors = self.freeRaums["46(E)"] else {

            return 0
        }
        
        return floors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GebCell", for: indexPath) as! GebCollectionViewCell
        
//        print("\nCell\(indexPath): \(cell)\n")
//        print("Cell\(indexPath) Subviews: \(cell.subviews)\n")
        
        guard let floors = self.freeRaums["46(E)"] else {
            
            return cell
        }
        
        let geb = "46(E)"
        let gebNummerMitLetter = geb.utf8.reduce(0, { result, codeUnit in result + Int(codeUnit) })
        
        for (index, floor) in floors.keys.enumerated() {

            if indexPath.item == index {

                let floorPlanTag = gebNummerMitLetter + floor
                
                cell.gebLabel.text = "Gebäude " + geb + ": Floor \(floor)"
                cell.floorPlanView.image = UIImage(ciImage: IPEngine.floorPlans[floorPlanTag]!.image)
                
                floors[floor]!.forEach { raumPlan in
                    
                    let raumPlanTag = floorPlanTag + raumPlan.raum
                    let raumButton = self.freeRaumButtons[floorPlanTag]!.filter({ $0.tag ==  raumPlanTag}).first
                    
                    if raumButton != nil {
                    
                        cell.addSubview(raumButton!)
                    }
                }
                
                break
            }
        }
        
        return cell
    }
    
    func generateNavigationConfirmAlert(for freeRaum: (geb: String, floor: Int, raum: Int, duration: String)) {
        
        let title = "Raum: \(freeRaum.raum)"
        let message = "Free for next " + freeRaum.duration
        
        let navigationConfirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let navigateAction = UIAlertAction(title: "Navigate Me", style: .default) { alertAction in
            
//            print("Hello, please navigate me to " + title + " of Gebäude " + freeRaum.geb + ": Floor \(freeRaum.floor)\n")
            
            let googleMapViewController = self.storyboard!.instantiateViewController(withIdentifier: "GoogleMapView") as! GoogleMapViewController
            googleMapViewController.geb = freeRaum.geb
            googleMapViewController.floor = freeRaum.floor
            googleMapViewController.raum = freeRaum.raum
            googleMapViewController.duration = freeRaum.duration
            
            self.navigationController!.pushViewController(googleMapViewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        navigationConfirmAlert.addAction(navigateAction)
        navigationConfirmAlert.addAction(cancelAction)
        
        self.present(navigationConfirmAlert, animated: true)
    }
    
    func generateFreeRaumButtons() {

        IPEngine.floorPlans.forEach { floorPlan in
            
            self.freeRaumButtons[floorPlan.key] = [UIButton]()
            
            floorPlan.value.buttonFrames.forEach { buttonFrame in
                
                var buttonFontSize = CGFloat(30)
                
                let raumButton = UIButton(frame: buttonFrame.value)
                let raumButtonTag = floorPlan.key + buttonFrame.key
                
                raumButton.tag = raumButtonTag
                raumButton.backgroundColor = UIColor.green
                raumButton.setTitle("\(buttonFrame.key)", for: .normal)
                
                if 12 == buttonFrame.key || 29 == buttonFrame.key || 133 == buttonFrame.key {
                    
                    buttonFontSize = CGFloat(25)
                    
                } else if 32 == buttonFrame.key || 332 == buttonFrame.key || 334 == buttonFrame.key {
                    
                    buttonFontSize = CGFloat(20)
                    
                } else if 35 == buttonFrame.key || 36 == buttonFrame.key {
                    
                    buttonFontSize = CGFloat(15)
                }
                
                raumButton.titleLabel!.font = raumButton.titleLabel!.font.withSize(buttonFontSize)
                raumButton.setTitleColor(UIColor.black, for: .normal)
                raumButton.addTarget(self, action: #selector(FreeRaumViewController.navigateMeInThisRaum(_:)), for: .touchUpInside)
                
                self.freeRaumButtons[floorPlan.key]! += [raumButton]
            }
        }
    }
    
    func startImageProcessor() {
        
//        print("After View Loading ...\n")
//        print("Start Image Processor ...\n")
        
        let widthDiffBetweenCollectionViewAndCell = CGFloat(45)
        let widthDiffBetweenCellAndImageFrame = CGFloat(40)
        
        let heightDiffBetweenCollectionViewAndCell = CGFloat(178)
        let heightDiffBetweenCellAndImageFrame = CGFloat(83)
        
        let imageFrameWidth = self.gebCollectionView.frame.width - (widthDiffBetweenCollectionViewAndCell + widthDiffBetweenCellAndImageFrame)
        let imageFrameHeight = self.gebCollectionView.frame.height - (heightDiffBetweenCollectionViewAndCell + heightDiffBetweenCellAndImageFrame)
        
//        let cellFrameWidth = self.gebCollectionView.frame.width - widthDiffBetweenCollectionViewAndCell
//        let cellFrameHeight = self.gebCollectionView.frame.height - heightDiffBetweenCollectionViewAndCell

        let imageFrame = CGRect(x: CGFloat(20), y: CGFloat(62), width: imageFrameWidth, height: imageFrameHeight)
//        let cellFrame = CGRect(x: CGFloat(0), y: CGFloat(89), width: cellFrameWidth, height: cellFrameHeight)

        IPEngine.imageViewFrame = imageFrame
//        ImageProcessor.parentViewFrames = [cellFrame, self.gebCollectionView.frame]
        IPEngine.processImage()
        
        self.generateFreeRaumButtons()
    }
    
    func processDidComplete(then dto: Any) {
        
        guard let freeRaumDTO = dto as? [FreeRaumDTO],
                !freeRaumDTO.isEmpty else {
            
            DispatchQueue.main.async {
                
                self.gebCollectionView.isHidden = false
            }
            
            return
        }
        
        DispatchQueue.main.async {
            
            // reset free raums dictionary
            self.freeRaums = [String : [Int : [(raum: Int, duration: String)]]]()
            
//            print("Free Raums Count: \(dto.count)\n")
            
            freeRaumDTO.forEach { freeRaum in
             
//                print("Geb: " + freeRaum.geb)
//                print("Floor: \(freeRaum.floor)")
//                print("Raum: \(freeRaum.raum)")
//                print("Duration: \(freeRaum.duration)\n")

                if !self.freeRaums.keys.contains(freeRaum.geb) {
                    
                    self.freeRaums[freeRaum.geb] = [Int : [(raum: Int, duration: String)]]()
                }
                    
                if !self.freeRaums[freeRaum.geb]!.keys.contains(freeRaum.floor) {
                
                    self.freeRaums[freeRaum.geb]![freeRaum.floor] = [(raum: Int, duration: String)]()
                }
                
                self.freeRaums[freeRaum.geb]![freeRaum.floor]! += [(freeRaum.raum, freeRaum.duration)]
            }
            
//            print("Free Raums Dictionary:")
//            print(self.freeRaums.description)
            
            self.gebCollectionView.isHidden = false
            self.gebCollectionView.reloadData()
        }
    }
    
    func processDidAbort(reason message: String) {
        
        DispatchQueue.main.async {
            
//            print("Process is aborted.")
//            print("Reason: " + message)
            
            self.gebCollectionView.isHidden = true
            
            let abortAlert = UIAlertController(title: "Process is aborted.", message: "Reason: " + message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            abortAlert.addAction(cancelAction)
            self.present(abortAlert, animated: true)
        }
    }
    
}
