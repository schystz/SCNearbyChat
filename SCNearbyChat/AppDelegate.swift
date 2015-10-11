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
        window?.tintColor = GlobalTintColor
        UILabel.appearance().font = UIFont(name: "Roboto-Light", size: 14)
        if #available(iOS 9.0, *) {
            UILabel.appearanceWhenContainedInInstancesOfClasses([ UITableViewCell.self ]).font = UIFont(name: "Roboto", size: 16)
        } else {
            // Fallback on earlier versions
        }
        
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName : UIFont(name: "Roboto", size: 18)! ]
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName : UIFont(name: "Roboto", size: 16)! ], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Roboto", size: 11)!], forState: .Normal)
        
        // Start advertising if needed
        if (SZUser.sharedInstance.visibleToOthers) {
            SZDiscoveryManager.sharedInstance.advertiser.startAdvertisingPeer()
        }
        
        return true
    }


}

