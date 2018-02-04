//
//  AppEngine.swift
//  AppEngine
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class AppEngine: RESTServiceDelegate {
    
    let s2TGebPlan = S2TGebPlanService()
    
    // app engine start flag
    var isStarted = false
    
    // last time searched date time
    var previousSearch: Date?
    
    // app data decision tree
    var department: Department
    
    // index mapping of geb, floor, raum with S2TGebPlan's Raum field
    var mapWithS2T = [String : [Int]]()
    
    var delegate: AppEngineDelegate?
    
    init() {
        
        previousSearch = nil
        delegate = nil
        
        // static mapping
        // floor mapping with raums
        let floor2Raums = [0: [9], 1 : [105, 107, 112, 121, 129, 131, 133, 139], 3 : [332]]
        
        var raums = [Raum](), floors = [Floor]()
        
        floor2Raums.forEach { floor, raumNumbers in
            
            raums = []
            raumNumbers.forEach { rn in
                
                raums += [Raum(number: rn)]
            }
            
            floors += [Floor(number: floor, raums: raums)]
        }
        
        let geb = Geb(name: "46(E)", floors: floors)
        department = Department(name: "Angewandte Informatik", gebs: [geb])
    }
    
    private func startEngine() {
        
    }
    
    private func stopEngine() {
        
    }
    
    private func restartEngine() {
        
        stopEngine()
        startEngine()
    }
    
    private func startProcess() {
        
    }
    
    func searchFreeRaums(on search: Date) {
        
        var isSearchedLastTime = false
        
        if previousSearch == nil || (previousSearch != nil && isSearchedLastTime = Utils.onlyDateEqual(search, to: previousSearch!)) {
        
            switch self.isStarted {
                
                case true:
                    self.restartEngine()
                
                case false:
                    self.isStarted = true
                    self.startEngine()
            }
        }
        
        // do nothing, if search date time  == last time searched date time
        guard !(isSearchedLastTime && Utils.onlyTimeEqual(search, to: previousSearch!)) else {
            
            return
        }
        
        startProcess()
    }
}
