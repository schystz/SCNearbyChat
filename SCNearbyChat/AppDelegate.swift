//
//  AppDelegate.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Customize UI
        window?.tintColor = UIColor(red: (60/255.0), green: (149/255.0), blue: (99/255.0), alpha: 1)
        
        // Start advertising if needed
        if (SZUser.sharedInstance.visibleToOthers) {
            SZDiscoveryManager.sharedInstance.advertiser.startAdvertisingPeer()
        }
        
        return true
    }


}

