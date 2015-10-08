//
//  SZHelper.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 08/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import Foundation

class SZHelper {
    
    static func extractInitialsForName(name: String) -> String {
        var initial = ""
        let parts = name.componentsSeparatedByString(" ")
        
        if (parts.count > 1) {
            initial = (parts[0] as NSString).substringToIndex(1) + (parts[1] as NSString).substringToIndex(1)
        } else {
            if (name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1) {
                initial = (name as NSString).substringToIndex(2)
            } else {
                initial = name
            }
        }
        
        return initial.uppercaseString
    }
    
}