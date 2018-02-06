//
//  ViewController.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AppEngineDelegate {
    
    let app = AppEngine()
    
    var freeRaums = [FreeRaumDTO]()
    
    @IBOutlet weak var searchDateTime: UIDatePicker!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        app.delegate = self
    }
    
    @IBAction func searchFreeRaums(_ sender: UIButton) {
        
        print("Date Picker Date: " + searchDateTime.date.description)
        print()
        
        app.search = searchDateTime.date
        app.searchFreeRaums()
    }
    
    func processDidComplete(then dto: [FreeRaumDTO]) {
        
        DispatchQueue.main.async {
            
            self.freeRaums = dto
            
            print("Free Raums Count: \(self.freeRaums.count)")
        }
    }
    
    func processDidAbort(reason message: String) {
        
    }
    
}
