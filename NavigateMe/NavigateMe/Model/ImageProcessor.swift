//
//  ImageProcessor.swift
//  NavigateMe
//
//  Created by mahbub on 2/16/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation
import CoreImage
import TesseractOCR

class ImageProcessor {
    
    static func processImage(floor: Int, freeRaums: [Int], imageViewFrame: CGRect, parentViewFrames: CGRect...) -> (image: CIImage, buttonFrames: [Int : CGRect]) {
        
        var floorPlanCIImage = CIImage(contentsOf: Bundle.main.url(forResource: "E\(floor)", withExtension: "png")!)!
        
        let orginalFloorPlanWidth = floorPlanCIImage.extent.width
        let orginalFloorPlanHeight = floorPlanCIImage.extent.height
        
        let imageContext = CIContext()
        let textDetectorInFloorPlan = CIDetector(ofType: CIDetectorTypeText, context: imageContext, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        let textFeatures = textDetectorInFloorPlan.features(in: floorPlanCIImage)
        
        // doing image transformation in device coordinate system
        let scaleX = imageViewFrame.width / orginalFloorPlanWidth
        let scaleY = imageViewFrame.height / orginalFloorPlanHeight
        let affineScaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        var i = 0, buttonFrames = [Int : CGRect]()
        
        for textIndex in textFeatures.indices {
            
            let textFeature = textFeatures[textIndex] as! CITextFeature
            
            i += 1
            
            print("Before Rect Increase: \(textFeature.bounds)\n")
            let textRect = textFeature.bounds.insetBy(dx: CGFloat(-5), dy: CGFloat(-5))
            print("After Rect Increase: \(textRect)\n")
            
            if let tesseract = G8Tesseract(language: "eng") {
                
                let textCGImage = imageContext.createCGImage(floorPlanCIImage, from: textRect)!
                let image = UIImage(cgImage: textCGImage).scaleImage(640)!
                
                tesseract.engineMode = .tesseractCubeCombined
                tesseract.pageSegmentationMode = .auto
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()
                let ocrText = tesseract.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Image \(i): OCR Result: " + ocrText + "\n")
            
                guard let raum = Int(ocrText),
                        freeRaums.contains(raum) else {
                    
                    continue
                }
                
                print("Rect Origin (X,Y): (\(textRect.origin.x), \(textRect.origin.y))\n")
                print("Rect Min (X,Y): (\(textRect.minX), \(textRect.minY))\n")
                print("Rect Max (X,Y): (\(textRect.maxX), \(textRect.maxY))\n")
                
                let buttonOrigin = CGPoint(x: textRect.origin.x, y: textRect.maxY)
                let translationX = CGFloat(0)
                let translationY = orginalFloorPlanHeight - (CGFloat(2) * buttonOrigin.y)
                let affineTranslationTransform = CGAffineTransform(translationX: translationX, y: translationY)
                
                var buttonFrame = CGRect(origin: buttonOrigin, size: textRect.size)
                
                // doing button transformation in device coordinate system
                buttonFrame = buttonFrame
                                        .applying(affineTranslationTransform)
                                        .applying(affineScaleTransform)
                
                buttonFrame.origin.x += (imageViewFrame.origin.x + parentViewFrames.reduce(CGFloat(0), { (result, frame) in result + frame.origin.x }))
                buttonFrame.origin.y += (imageViewFrame.origin.y + parentViewFrames.reduce(CGFloat(0), { (result, frame) in result + frame.origin.y }))
                
                buttonFrames[raum] = buttonFrame
            }
        }
        
        floorPlanCIImage = floorPlanCIImage.transformed(by: affineScaleTransform)
        
        return (floorPlanCIImage, buttonFrames)
    }
    
}
