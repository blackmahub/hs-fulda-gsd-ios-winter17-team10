//
//  GoogleDirection.swift
//  NavigateMe
//
//  Created by mahbub on 2/27/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import Foundation

struct GoogleDirection: Decodable {
    
    var routes: [GoogleRoute]
    var status: String
}
