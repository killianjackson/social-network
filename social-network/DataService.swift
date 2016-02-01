//
//  DataService.swift
//  social-network
//
//  Created by Killian Jackson on 1/31/16.
//  Copyright © 2016 Killian Jackson. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://social-network-pkj.firebaseio.com")
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}