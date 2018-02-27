//
//  RESTService.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class RESTService {
    
    var networkProtocol: String
    var host: String
    var port: Int?
    
    var delegate: RESTServiceDelegate? = nil
    
    init(with networkProtocol: String, host: String, port: Int? = nil) {
        
        self.networkProtocol = networkProtocol
        self.host = host
        self.port = port
    }
    
    func callbackAfterCompletion(data: Data?, response: URLResponse?, error: Error?) {}
    
    func generateURL(using path: String, query: [String : String?]?) -> URL? {
        
        var components = URLComponents()
        
        components.scheme = self.networkProtocol
        components.host = self.host
        
        if let port = self.port {
        
            components.port = port
        }
        
        components.path = path
        
        if let query = query {
            
            var queryItems = [URLQueryItem]()
            
            for (name, value) in query {
                queryItems += [URLQueryItem(name: name, value: value)]
            }
            
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    func processGET(for url: URL?) {
        
        guard let url = url else {
            
            print("Invalid URL String")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession(configuration: URLSessionConfiguration.default)
            .dataTask(with: request, completionHandler: callbackAfterCompletion)
            .resume()
    }
    
}
