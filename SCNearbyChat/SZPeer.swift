//
//  SZPeer.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 08/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import MultipeerConnectivity

class SZPeer: NSObject {
    
    // MARK: - Properties
    
    let peerId: MCPeerID!
    var initial: String!
    var name: String!
    var bio: String = ""
    var gender: Gender = .Unspecified
    var connected = false
    var chatMessages = [JSQMessage]()
    
    // MARK: - Private Methods
    
    init(peerID: MCPeerID, discoveryInfo: Dictionary<String, String>?) {
        peerId = peerID
        name = peerID.displayName
        initial = SZHelper.extractInitialsForName(name)
        
        super.init()
        
        extractBioAndGender(discoveryInfo)
    }
    
    private func extractBioAndGender(discoveryInfo: Dictionary<String, String>?) {
        if (discoveryInfo == nil) { return }
        
        if let bioRaw = discoveryInfo!["bio"] {
            if (bioRaw.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1) {
                gender = Gender(rawValue: Int((bioRaw as NSString).substringToIndex(1))!)!
                bio = (bioRaw as NSString).substringFromIndex(1)
            }
        }
    }
    
}
