//
//  SZDiscoveryManager.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SZDiscoveryManagerDelegate {
    func didFoundPeer()
    func didLostPeer()
    func didReceivedInvitationFromPeer(peerId: MCPeerID)
    func didConnectWithPeer(peerId: MCPeerID)
}

class SZDiscoveryManager: NSObject {
    
    // MARK: - Properties
    
    static let sharedInstance = SZDiscoveryManager()
    static let serviceType = "sc-chatservice"
    
    var peers = [SZPeer]()
    var delegate: SZDiscoveryManagerDelegate?
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    private var peerId: MCPeerID!
    
    // MARK: - Private Methods
    
    override init() {
        super.init()
        initPeerId()
        initSession()
        initAdvertiser()
        initBrowser()
    }
    
    private func initPeerId() {
        peerId = MCPeerID(displayName: SZUser.sharedInstance.username)
    }
    
    private func initSession() {
        session = MCSession(peer: peerId)
        session.delegate = self
    }
    
    private func initAdvertiser() {
        let info = ["bio" : String(SZUser.sharedInstance.gender.rawValue) + SZUser.sharedInstance.bio]
        advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: info, serviceType: SZDiscoveryManager.serviceType)
        advertiser.delegate = self
    }
    
    private func initBrowser() {
        browser = MCNearbyServiceBrowser(peer: peerId, serviceType: SZDiscoveryManager.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    // MARK: - Public Methods
    
    func refreshAdvertisingInfo() {
        peerId = nil
        initPeerId()
        
        advertiser.stopAdvertisingPeer()
        advertiser = nil
        initAdvertiser()
    }
    
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension SZDiscoveryManager: MCNearbyServiceAdvertiserDelegate {
    
    @objc func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("advertiser:didNotStartAdvertisingPeer: \(error)")
    }
    
    @objc func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("advertiser:didReceiveInvitationFromPeer: \(peerID)")
    }
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension SZDiscoveryManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("browser:didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("browser:foundPeer: \(peerID) info: \(info)")
        
        // Check first if the peerID is already discovered
        for peer in peers {
            if (peer.peerId == peerID) {
                return // peerID is already discovered
            }
        }
        
        // Add to discovered peers
        peers.append(SZPeer(peerID: peerID, discoveryInfo: info))
        
        // Inform delegate
        delegate?.didFoundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("browser:lostPeer: \(peerID)")
        
        // Remove peer from discovered peers
        for (index, peer) in peers.enumerate() {
            if (peer.peerId == peerID) {
                peers.removeAtIndex(index)
                break
            }
        }
        
        // Inform delegate
        delegate?.didLostPeer()
    }
    
}

// MARK: - MCSessionDelegate

extension SZDiscoveryManager: MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer
        peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String,
        fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer
        peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer
        peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
}