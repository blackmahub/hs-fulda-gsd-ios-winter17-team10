//
//  S2TGebPlanService.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class S2TGebPlanService: RESTService {
    
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
            
            let s2TGebPlans = try JSONDecoder().decode([S2TGebPlan].self, from: data)
            self.delegate?.dataDidReceive(data: s2TGebPlans)
            
        } catch let jsonError {
            
            print("JSON Error:\(jsonError)")
        }
    }
    
    func get(of gebs: [String], on date: Date) {
        
        guard !gebs.isEmpty else {
            
            print("Service Error: Geb list is Empty.")
            return
        }
        
        var query = [String : String?]()
        
        query["entryLimit"] = "\(1100)"
        query["nofill"] = "\(1)"
        query["date"] = date.string(format: "dd-MM-yyyy")
        
        let requestUrl = "/hfg/rest/st/getGebPlan/" + gebs.joined(separator: ",") + "/"
        let url = self.generateURL(using: requestUrl, query: query)
        
        self.processGET(for: url)
    }
    
}
