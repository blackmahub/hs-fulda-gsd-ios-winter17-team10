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
        
        s2TGebPlan.delegate = self
    }
    
    // load data into decision tree
    private func startEngine() {
        
        // call RESTful API to fetch geb plan from S2T
        s2TGebPlan.get(of: nil, on: self.search!)
    }
    
    // refresh decision tree
    private func stopEngine() {
        
        var raum: Raum? = nil
        
        // reset raum schedules
        department.gebs.forEach { geb in
            
            geb.floors.forEach { floor in
                
                for raumIndex in floor.raums.indices {
                    
                    raum = floor.raums[raumIndex]
                    raum!.status = .FREE(Utils.defaultFreeDuration())
                    raum!.schedules.removeAll()
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
        
        var raum: Raum? = nil, freeSchedules = [Schedule](), beforeBeginns = [Schedule](), minBeforeBeginn: Schedule? = nil
        
        department.gebs.forEach { geb in
            
            geb.floors.forEach { floor in
                
                for raumIndex in floor.raums.indices {
                    
                    raum = floor.raums[raumIndex]
                    
                    // filter schedules where search date time are not within beginn and ende range
                    freeSchedules = raum!.schedules.filter { schedule in
                        
                        return !((schedule.beginn == self.search! || schedule.beginn < self.search!) && self.search! < schedule.ende)
                    }
                    
                    if freeSchedules.count == 0 {
                        
                        raum!.status = .OCCUPIED
                    
                    } else {
                    
                        // filter schedules where search date time is less than beginn
                        beforeBeginns = freeSchedules.filter { freeSchedule in
                            
                            return self.search! < freeSchedule.beginn
                        }
                        
                        if beforeBeginns.count == 0 {
                            
                            raum!.status = .FREE(Utils.freeDurationTillUniversityClose(from: self.search!))
                        
                        } else {
                            
                            minBeforeBeginn = beforeBeginns.min(by: { (schedule1, schedule2) -> Bool in
                                
                                return schedule1.beginn < schedule2.beginn
                            })
                            
                            raum!.status = .FREE(minBeforeBeginn!.beginn.timeIntervalSince1970 - self.search!.timeIntervalSince1970)
                        }
                    }
                }
            }
        }
        
        self.previousSearch = self.search!
        self.search = nil
        
        let freeRaumDTOs = generateFreeRaumDTO()
        self.delegate?.processDidComplete(then: freeRaumDTOs)
    }
    
    func dataDidReceive(data: [S2TGebPlan]) {
        
        guard !data.isEmpty else {
            
            self.delegate?.processDidAbort(reason: "No Geb Plan is found from System2Teach.")
            return
        }
        
        var gebRaums = [Substring](), mappedIndices = [Int](), beginn: Date? = nil, ende: Date? = nil, raumFromS2T: String? = nil, isScheduleAppended = false, geb: Geb? = nil, floor: Floor? = nil, raum: Raum? = nil
        
        data.forEach { gebPlan in
            
            gebRaums = gebPlan.Raum.split(separator: "/")
            
            raumFromS2T = String(gebRaums[0])
            
            beginn = Utils.millisecondToDate(Double(gebPlan.Beginn))
            ende = Utils.millisecondToDate(Double(gebPlan.Ende))
            
            if mapWithS2T.keys.contains(raumFromS2T!) {
            
                // mapping contains geb, floor, raum numbers
                mappedIndices = mapWithS2T[raumFromS2T!]!
                
                // append raum schedules
                department.gebs[mappedIndices[0]].floors[mappedIndices[1]].raums[mappedIndices[2]].schedules += [Schedule(beginn: beginn!, ende: ende!)]
            
            } else {
            
                isScheduleAppended = false
                
                gebRaums = raumFromS2T!.split(separator: ".")
                
                for gebIndex in department.gebs.indices {
                    
                    geb = department.gebs[gebIndex]
                    
                    for floorIndex in geb!.floors.indices {
                        
                        floor = geb!.floors[floorIndex]
                        
                        for raumIndex in floor!.raums.indices {
                            
                            raum = floor!.raums[raumIndex]
                            
                            if raum!.number == Int(gebRaums[1]) {
                                
                                raum!.schedules += [Schedule(beginn: beginn!, ende: ende!)]
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
        
        guard Utils.withinUniversityTime(self.search!) else {
            
            self.delegate?.processDidAbort(reason: "Search date time is need to be with in university open and close times.")
            return
        }
        
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
    
    func generateFreeRaumDTO() -> [FreeRaumDTO] {
        
        var freeRaumDTOs = [FreeRaumDTO]()
        
        department.gebs.forEach { geb in
            
            geb.floors.forEach { floor in
                
                freeRaumDTOs += floor.raums.filter { raum -> Bool in
                    
                    var isFree: Bool
                    
                    switch raum.status {
                        
                        case .FREE(_):
                            isFree = true
                        
                        case .OCCUPIED:
                            isFree = false
                        
                    }
                    
                    return isFree
                }
                .map { raum -> FreeRaumDTO in
                    
                    var freeTimeInterval: TimeInterval
                    
                    switch raum.status {
                        
                        case let .FREE(duration):
                            freeTimeInterval = duration
                        
                        case .OCCUPIED:
                            freeTimeInterval = 0.0
                    }
                    
                    return FreeRaumDTO(geb: geb.name, floor: floor.number, raum: raum.number, duration: Utils.secondToDateString(freeTimeInterval, format: "HH:mm"))
                }
            }
        }
        
        return freeRaumDTOs
    }
    
}
