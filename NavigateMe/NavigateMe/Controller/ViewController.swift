//
//  ViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit
import CoreImage
import TesseractOCR

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
        
        // detect text on image and print that text on console
        let floorPlanImage = CIImage(contentsOf: Bundle.main.url(forResource: "E1", withExtension: "png")!)!
        let imageContext = CIContext()
        
        let textDetectorInFloorPlan = CIDetector(ofType: CIDetectorTypeText, context: imageContext, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
        let features = textDetectorInFloorPlan.features(in: floorPlanImage)
        var i = 0
        
        for feature in features {
            
            i += 1
            
            let textFeature = feature as! CITextFeature
            
            print("Before Rect Increase: \(textFeature.bounds)\n")
            let textRect = textFeature.bounds.insetBy(dx: CGFloat(-5), dy: CGFloat(-5))
            print("After Rect Increase: \(textRect)\n")
            
            let textCGImage = imageContext.createCGImage(floorPlanImage, from: textRect)!
            
            do {
                
                try imageContext.writePNGRepresentation(of: CIImage(cgImage: textCGImage), to: URL(fileURLWithPath: "/Users/mahbub/Pictures/Raum-\(i).png"), format: kCIFormatRGBA8, colorSpace: floorPlanImage.colorSpace!, options: [:])
                
            } catch let err {
                print("\nERROR: " + err.localizedDescription + "\n")
            }
            
            let image = UIImage(cgImage: textCGImage).scaleImage(640)!
            
            if let tesseract = G8Tesseract(language: "eng") {
                tesseract.engineMode = .tesseractCubeCombined
                tesseract.pageSegmentationMode = .auto
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()
                print("Image \(i): OCR Result: \(tesseract.recognizedText)\n")
            }
        }
        
        print("\nDate Picker Date: " + searchDateTime.date.description + "\n")
        
//        app.search = searchDateTime.date
//        app.searchFreeRaums()
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
        
        // reset free raums dictionary
        self.freeRaums = [String : [Int : [String]]]()
        
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

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
