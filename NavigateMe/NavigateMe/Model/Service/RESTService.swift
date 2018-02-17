//
//  RESTService.swift
//  NavigateMe
//
//  Created by mahbub on 1/20/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

class RESTService {
    
    static private let networkProtocol = "http"
    static private let host = "193.174.26.57"
    static private let port = 8080
    
    var delegate: RESTServiceDelegate? = nil
    
    func callbackAfterCompletion(data: Data?, response: URLResponse?, error: Error?) {}
    
    func generateURL(using path: String, query: [String : String?]?) -> URL? {
        
        var components = URLComponents()
        
        components.scheme = RESTService.networkProtocol
        components.host = RESTService.host
        components.port = RESTService.port
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
