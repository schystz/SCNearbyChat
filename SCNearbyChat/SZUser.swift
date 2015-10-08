//
//  SZUser.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

enum Gender: Int {
    case Male = 1
    case Female = 2
    case Unspecified = 0
    
    var description : String {
        switch self {
        case .Male: return "Male";
        case .Female: return "Female";
        case .Unspecified: return "Unspecified";
        }
    }
}

class SZUser {
    
    // MARK: - Properties
    
    static let sharedInstance = SZUser()
    
    var username = UIDevice.currentDevice().name
    var bio = ""
    var gender: Gender = .Unspecified
    var visibleToOthers = true
    
    // MARK: - Private Methods
    
    init() {
        // Get user profile from persistent store
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let savedUsername = userDefaults.stringForKey("username") {
            username = savedUsername
        }
        
        if let savedBio = userDefaults.stringForKey("bio") {
            bio = savedBio
        }
        
        gender = Gender(rawValue: userDefaults.integerForKey("gender"))!
        
        if let _ = userDefaults.objectForKey("visible") {
            visibleToOthers = userDefaults.boolForKey("visible")
        }
    }
    
    // MARK: - Public Methods
    
    func initials() -> String {
        return SZHelper.extractInitialsForName(username)
    }
    
    func saveProfile() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(username, forKey: "username")
        userDefaults.setObject(bio, forKey: "bio")
        userDefaults.setInteger(gender.rawValue, forKey: "gender")
        userDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("UserProfileUpdated", object: nil)
    }
    
    func saveVisibility() {
        NSUserDefaults.standardUserDefaults().setBool(visibleToOthers, forKey: "visible")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}