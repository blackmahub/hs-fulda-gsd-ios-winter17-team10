//
//  AppEngineDelegate.swift
//  NavigateMe
//
//  Created by mahbub on 2/4/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

protocol AppEngineDelegate {
    
    func processDidComplete(then dto: [FreeRaumDTO]?)
    
    func processDidAbort(reason message: String)
    
}
