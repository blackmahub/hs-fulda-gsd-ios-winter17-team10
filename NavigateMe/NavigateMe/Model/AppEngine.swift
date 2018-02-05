//
//  AppEngine.swift
//  AppEngine
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class AppEngine: RESTServiceDelegate {
    
    private let s2TGebPlan = S2TGebPlanService()
    
    // app engine start flag
    private var isStarted = false
    
    // app data decision tree
    private var department: Department
    
    // index mapping of geb, floor, raum with S2TGebPlan's Raum field
    private var mapWithS2T = [String : [Int]]()
    
    // last time searched date time
    private var previousSearch: Date?
    
    // search date time
    var search: Date?
    
    var delegate: AppEngineDelegate?
    
    init() {
        
        previousSearch = nil
        search = nil
        delegate = nil
        
        s2TGebPlan.delegate = self
        
        // static mapping
        // floor mapping with raums
        let floor2Raums = [0: [9], 1 : [105, 107, 112, 121, 129, 131, 133, 139], 3 : [332]]
        
        var raums = [Raum](), floors = [Floor]()
        
        floor2Raums.forEach { floor, raumNumbers in
            
            // reset raums array
            raums.removeAll()
            
            raumNumbers.forEach { rn in
                
                raums += [Raum(number: rn)]
            }
            
            floors += [Floor(number: floor, raums: raums)]
        }
        
        let geb = Geb(name: "46(E)", floors: floors)
        department = Department(name: "Angewandte Informatik", gebs: [geb])
    }
    
    // load data into decision tree
    private func startEngine() {
        
        // call RESTful API to fetch geb plan from S2T
        s2TGebPlan.get(of: nil, on: self.search!)
    }
    
    // refresh decision tree
    private func stopEngine() {
        
        // reset raum schedules
        department.gebs.forEach { geb in
            
            geb.floors.forEach { floor in
                
                floor.raums.forEach { raum in
                    
                    raum.status = .FREE(Utils.defaultFreeDuration(from: self.search!))
                    raum.schedule.removeAll()
                }
            }
        }
    }
    
    // reload data into decision tree
    private func restartEngine() {
        
        stopEngine()
        startEngine()
    }
    
    // make decision from decision tree
    private func startProcess() {
        
        var freeSchedules = [Schedule](), freeEndee: Date? = nil
        
        department.gebs.forEach { geb in
            
            geb.floors.forEach { floor in
                
                floor.raums.forEach { raum in
                    
                    freeSchedules = raum.schedules.filter { schedule in
                        
                        return !((schedule.beginn == self.search! || schedule.beginn < self.search!) && self.search! < schedule.ende)
                    }
                    
                    if freeSchedules.count == 0 {
                        
                        raum.status = .OCCUPIED
                    
                    } else {
                    
                        freeEndee = Utils.defaultFreeDuration(from: self.search!)
                        
                        freeSchedules.forEach { freeSchedule in
                            
                            
                            if freeSchedule
                        }
                    }
                }
            }
        }
        
        self.previousSearch = self.search!
        self.search = nil
        
        self.delegate?.processDidComplete()
    }
    
    func dataDidReceive(data: [S2TGebPlan]) {
        
        guard !data.isEmpty else {
            
            self.delegate?.processDidAbort()
            return
        }
        
        var gebRaums = [String](), mappedIndices = [Int](), beginn: Date? = nil, ende: Date? = nil, raumFromS2T: String? = nil, isScheduleAppended = false
        
        data.forEach { gebPlan in
            
            gebRaums = gebPlan.Raum.split(separator: "/")
            
            raumFromS2T = gebRaums[0]
            
            beginn = Utils.millisecondToDate(Double(gebPlan.Beginn))
            ende = Utils.millisecondToDate(Double(gebPlan.Ende))
            
            if mapWithS2T.keys.contains(raumFromS2T!) {
            
                // mapping contains geb, floor, raum numbers
                indexMapping = mapWithS2T[raumFromS2T!]
                
                // append raum schedules
                department.gebs[mappedIndices[0]].floors[mappedIndices[1]].raums[mappedIndices[2]].schedules += [Schedule(beginn: beginn!, ende: ende!)]
            
            } else {
            
                isScheduleAppended = false
                
                gebRaums = raumFromS2T!.split(separator: "\\.")
                
                for (gebIndex, geb) in department.gebs {
                    
                    for (floorIndex, floor) in geb.floors {
                        
                        for (raumIndex, raum) in floor.raums {
                            
                            if raum.number == Int(gebRaums[1]) {
                                
                                raum.schedules += [Schedule(beginn: beginn!, ende: ende!)]
                                mapWithS2T[raumFromS2T!] = [gebIndex, floorIndex, raumIndex]
                                isScheduleAppended = true
                                break
                            }
                        }
                        
                        if isScheduleAppended {
                            break
                        }
                    }
                    
                    if isScheduleAppended {
                        break
                    }
                }
            }
        }
        
        startProcess()
    }
    
    func searchFreeRaums() {
        
        if previousSearch == nil || (previousSearch != nil && !Utils.onlyDateEqual(self.search!, to: self.previousSearch!)) {
        
            switch self.isStarted {
                
                case true:
                    self.restartEngine()
                
                case false:
                    self.isStarted = true
                    self.startEngine()
            }
            
            return
        }
        
        // do nothing, if search time == last searched time
        guard !Utils.onlyTimeEqual(self.search!, to: self.previousSearch!) else {
            
            return
        }
        
        startProcess()
    }
    
}
