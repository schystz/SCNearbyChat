//
//  SZTabBarController.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 09/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SZTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SZDiscoveryManager.sharedInstance.advertiserDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!NSUserDefaults.standardUserDefaults().boolForKey("InitialMessage")) {
            let alertController = UIAlertController(title: "Hello there!", message: "NearbyChat automatically search for users near you. Be sure to turn on your WiFi or Bluetooth to stay connected and discover users around you.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: nil))
            self .presentViewController(alertController, animated: true, completion: nil)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "InitialMessage")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}

extension SZTabBarController: SZDiscoveryManagerAdvertiserDelegate {
    
    func didReceivedInvitationFromPeer(peer: SZPeer) {
        let alertController = UIAlertController(title: "Chat Request", message: "\(peer.name) wants to chat with you.", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Accept", style: .Default, handler: { (action) -> Void in
            guard let handler = SZDiscoveryManager.sharedInstance.invitationHandler else {
                print("Invitation handler is empty!")
                return
            }
            
            // Inform other party that chat request was accepted
            handler(true, SZDiscoveryManager.sharedInstance.session)
            
            // Swith to first tab
            if (self.selectedIndex != 0) {
                self.selectedIndex = 0
            }
            
            // Send a notification that user has accepted an invitation
            // - DiscoveryController should present ChatController for this peer
            // - DiscoveryManager should mark session with peer as connected
            NSNotificationCenter.defaultCenter().postNotificationName("DidAcceptInvitation",
                object: self, userInfo: ["peer" : peer])
        }))
        
        alertController.addAction(UIAlertAction(title: "Decline", style: .Cancel, handler: { (action) -> Void in
            if let handler = SZDiscoveryManager.sharedInstance.invitationHandler {
                // Inform other party that chat request was denied
                handler(false, SZDiscoveryManager.sharedInstance.session)
            }
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}
