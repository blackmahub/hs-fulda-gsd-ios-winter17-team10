//
//  GoogleDirectionService.swift
//  NavigateMe
//
//  Created by mahbub on 2/27/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation
import CoreLocation

class GoogleDirectionService: RESTService {
    
    static private let networkProtocol = "https"
    static private let host = "maps.googleapis.com"
    
    init() {
        
        super.init(with: GoogleDirectionService.networkProtocol, host: GoogleDirectionService.host)
    }
    
    override func callbackAfterCompletion(data: Data?, response: URLResponse?, error: Error?) {
        
        if error != nil {
            
            print("Response Error: \(error!.localizedDescription)")
            return
        }
        
        guard let data = data else {
            
            print("Response Data: No Data is Found.")
            return
        }
        
        do {
            
            let googleDirection = try JSONDecoder().decode(GoogleDirection.self, from: data)
            self.delegate?.dataDidReceive(data: googleDirection)
            
        } catch let jsonError {
            
            print("JSON Error:\(jsonError)")
        }
    }
    
    func get(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        var query = [String : String?]()
        
        query["origin"] = "\(origin.latitude),\(origin.longitude)"
        query["destination"] = "\(destination.latitude),\(destination.longitude)"
        query["key"] = "AIzaSyA5WKLZCTreqWGGVNdeucTzqCgsLfEf8CU"
        query["mode"] = "walking"
        
        let requestUrl = "/maps/api/directions/json"
        let url = self.generateURL(using: requestUrl, query: query)
        
        self.processGET(for: url)
    }
    
}
