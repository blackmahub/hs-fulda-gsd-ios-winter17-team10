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
    
    // gebäude list
    var gebs: [String]?
    
    var delegate: AppEngineDelegate?
    
    init() {
        
        previousSearch = nil
        search = nil
        gebs = nil
        delegate = nil
        
        // static mapping
        // floor mapping with raums
        // TODO: fix missmatch with floor plan image
        let floor2Raums = [0: [6, 9, 12, 29, 32, 35, 36], 1 : [9, 105, 107, 112, 121, 129, 131, 133, 139], 3 : [322, 332, 334, 336]]
        
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
        
        print("Engine starting ...")
        
        // call RESTful API to fetch geb plan from S2T
        s2TGebPlan.get(of: self.gebs!, on: self.search!)
    }
    
    // refresh decision tree
    private func stopEngine() {
        
        print("Engine stopping ...")
        
        // reset raum schedules
        for gebIndex in department.gebs.indices {
            
            for floorIndex in department.gebs[gebIndex].floors.indices {
                
                for raumIndex in department.gebs[gebIndex].floors[floorIndex].raums.indices {
                    
                    department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status = .FREE(Date.defaultFreeDuration())
                    department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules.removeAll()
                }
            }
        }
    }
    
    // reload data into decision tree
    private func restartEngine() {
        
        print("Engine restarting ...")
        
        stopEngine()
        startEngine()
    }
    
    // make decision from decision tree
    private func startProcess() {
        
        print("\nProcess starting ...\n")
        
        var freeSchedules = [Schedule](), beforeBeginns = [Schedule](), minBeforeBeginn: Schedule? = nil
        
        for gebIndex in department.gebs.indices {
            
            print("Geb: " + department.gebs[gebIndex].name)
            
            for floorIndex in department.gebs[gebIndex].floors.indices {
                
                print("\nFloor: \(department.gebs[gebIndex].floors[floorIndex].number)")
                
                for raumIndex in department.gebs[gebIndex].floors[floorIndex].raums.indices {
                    
                    print("Raum: \(department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].number)")
                    print("Raum Schedules: \(department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules)")
                    print("Raum Status: \(department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status)")
                    
                    // if there is no schedule for this raum then continue to next raum
                    // and also reduce free duration from (uni close time - uni open time) to (uni close time - search time)
                    if department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules.count == 0 {
                        
                        // raum status is free
                        department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status = .FREE(self.search!.freeDurationTillUniversityClose())
                        
                        print()
                        continue
                    }
                    
                    let scheduleCount = department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules.count
                    
                    // filter schedules where search date time are not within beginn and ende range
                    freeSchedules = department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules.filter { schedule in
                        
                        return !((schedule.beginn == self.search! || schedule.beginn < self.search!) && self.search! < schedule.ende)
                    }
                    
                    print("Free Schedules: \(freeSchedules)")
                    
                    if freeSchedules.count == scheduleCount - 1 {
                    
                        // raum status is occupied
                        department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status = .OCCUPIED
                    
                    } else {
                    
                        // filter schedules where search date time is less than beginn
                        beforeBeginns = freeSchedules.filter { freeSchedule in
                            
                            return self.search! < freeSchedule.beginn
                        }
                        
                        if beforeBeginns.count == 0 {
                            
                            // raum status is free
                            department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status = .FREE(self.search!.freeDurationTillUniversityClose())
                        
                        } else {
                            
                            minBeforeBeginn = beforeBeginns.min(by: { (schedule1, schedule2) -> Bool in
                                
                                return schedule1.beginn < schedule2.beginn
                            })
                            
                            // raum status is free
                            department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status = .FREE(minBeforeBeginn!.beginn.timeIntervalSince1970 - self.search!.timeIntervalSince1970)
                        }
                    }
                    
                    print("Raum Status: \(department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].status)\n")
                }
            }
        }
        
        print("\n Departmant: \(department)\n")
        
        self.previousSearch = self.search!
        self.search = nil
        
        let freeRaumDTOs = generateFreeRaumDTO()
        
        print("\n Free Raum DTO: \(freeRaumDTOs)\n")
        
        self.delegate?.processDidComplete(then: freeRaumDTOs)
    }
    
    func dataDidReceive(data: [S2TGebPlan]) {
        
        guard !data.isEmpty else {
            
            print("No Geb Plan is found from System2Teach.")
            self.delegate?.processDidAbort(reason: "University is Closed.")
            return
        }
        
        print("\nInitial values of Decision Tree:\n")
        print("\(self.department)")
        
        var gebRaums = [Substring](), mappedIndices = [Int](), beginn: Date? = nil, ende: Date? = nil, raumFromS2T: String? = nil, isScheduleAppended = false
    
        print("\nData: \(data.count)\n")
        
        data.forEach { gebPlan in
            
            gebRaums = gebPlan.Raum.split(separator: "/")
            
            raumFromS2T = String(gebRaums[0])
            
            beginn = Date.millisecondToDate(Double(gebPlan.Beginn))
            ende = Date.millisecondToDate(Double(gebPlan.Ende))
            
            print("Raum: " + gebPlan.Raum)
            print("Beginn: \(beginn)")
            print("Ende: \(ende)\n")
            
            if mapWithS2T.keys.contains(raumFromS2T!) {
            
                // mapping contains geb, floor, raum numbers
                mappedIndices = mapWithS2T[raumFromS2T!]!
                
                // append raum schedules
                department.gebs[mappedIndices[0]].floors[mappedIndices[1]].raums[mappedIndices[2]].schedules += [Schedule(beginn: beginn!, ende: ende!)]
            
            } else {
            
                isScheduleAppended = false
                
                gebRaums = raumFromS2T!.split(separator: ".")
                
                for gebIndex in department.gebs.indices {
                    
                    for floorIndex in department.gebs[gebIndex].floors.indices {
                        
                        for raumIndex in department.gebs[gebIndex].floors[floorIndex].raums.indices {
                            
                            if department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].number == Int(gebRaums[1]) {
                                
                                department.gebs[gebIndex].floors[floorIndex].raums[raumIndex].schedules += [Schedule(beginn: beginn!, ende: ende!)]
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
        
        let recordCount = department.gebs[0].floors.reduce(0, { (result, floor) in

            result + floor.raums.reduce(0, { (result, raum) in
                
                result + raum.schedules.count
            })
        })
        
        print("\nRecord Count: \(recordCount)\n")
        
        // if S2T data count is not equal to transformed decision tree record count
        // then abort the process and check for data accuracy
        guard data.count == recordCount else {
            
            self.delegate?.processDidAbort(reason: "Data accuracy is failed, please check System2Teach data transformation block.")
            return
        }
        
        startProcess()
    }
    
    func searchFreeRaums() {
        
        print("In App Engine")
        
        guard self.search!.isWithinUniversityTime() else {
            
            self.delegate?.processDidAbort(reason: "Search date time is need to be with in university open and close times.")
            return
        }
        
        if previousSearch == nil || (previousSearch != nil && !self.search!.onlyDateEqual(to: self.previousSearch!)) {
        
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
        guard !self.search!.onlyTimeEqual(to: self.previousSearch!) else {
            
            print("do nothing, if search time == last searched time")
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
                    
                    return FreeRaumDTO(geb: geb.name, floor: floor.number, raum: raum.number, duration: Date(timeIntervalSince1970: freeTimeInterval).string(format: "HH:mm"))
                }
            }
        }
        
        return freeRaumDTOs
    }
    
}
