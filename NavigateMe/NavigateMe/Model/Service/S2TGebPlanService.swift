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
    
    func get(of geb: [String]?, on date: Date) {
        
        var query = [String : String?]()
        
        query["entryLimit"] = "\(25)"
        query["nofill"] = "\(0)"
        query["cache"] = "false"
        query["_"] = "\(1515166789828)"
        
        // TODO_LEARN_HOW_TO_ADD_REST_PATH_PARAMS
        // TODO_USE_GEB_VAR_IN_REST_PATH
        
        let url = self.generateURL(using: "/hfg/rest/st/getGebPlan/46(E)./", query: query)
        
        self.processGET(for: url)
    }
    
}
