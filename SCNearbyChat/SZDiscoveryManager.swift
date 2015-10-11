//
//  SZDiscoveryManager.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SZDiscoveryManagerBrowserDelegate {
    func didFoundPeer()
    func didLostPeer()
}

protocol SZDiscoveryManagerAdvertiserDelegate {
    func didReceivedInvitationFromPeer(peer: SZPeer)
}

protocol SZDiscoveryManagerSessionDelegate {
    func didConnectWithPeer(peer: SZPeer)
    func didNotConnectWithPeer(peer: SZPeer)
    func didReceivedMessage(message: String, fromPeer peer:SZPeer)
}

class SZDiscoveryManager: NSObject {
    
    // MARK: - Properties
    
    static let sharedInstance = SZDiscoveryManager()
    static let serviceType = "sc-chatservice"
    
    var peers = [SZPeer]()
    var browserDelegate: SZDiscoveryManagerBrowserDelegate?
    var advertiserDelegate: SZDiscoveryManagerAdvertiserDelegate?
    var sessionDelegate: SZDiscoveryManagerSessionDelegate?
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    var invitationHandler: ((Bool, MCSession) -> Void)?
    
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
    
    private func peerForPeerID(peerID: MCPeerID) -> SZPeer? {
        for peer in peers {
            if (peer.peerId.isEqual(peerID)) {
                return peer
            }
        }
        
        return nil
    }
    
    // MARK: - Public Methods
    
    func refreshAdvertisingInfo() {
        peerId = nil
        initPeerId()
        
        advertiser.stopAdvertisingPeer()
        advertiser = nil
        initAdvertiser()
    }
    
    func sendMessage(message: String, toPeer peer: SZPeer) {
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)!
        
        do {
            try session.sendData(data, toPeers: [peer.peerId], withMode: .Reliable)
            print(">> Message sent!")
        } catch {
            print(">> Message failed to sent!")
        }
    }
    
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension SZDiscoveryManager: MCNearbyServiceAdvertiserDelegate {
    
    @objc func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(">> \(__FUNCTION__) \(error)")
    }
    
    @objc func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void)
    {
        print(">> \(__FUNCTION__) \(peerID)")
        
        if let peer = peerForPeerID(peerID) {
            self.invitationHandler = invitationHandler
            advertiserDelegate?.didReceivedInvitationFromPeer(peer)
        }
    }
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension SZDiscoveryManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(">> \(__FUNCTION__) \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(">> \(__FUNCTION__) \(peerID)")
        
        // Check first if the peerID is already discovered
        if (peerForPeerID(peerID) != nil) {
            return
        }
        
        // Add to discovered peers
        peers.append(SZPeer(peerID: peerID, discoveryInfo: info))
        
        // Inform delegate
        browserDelegate?.didFoundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print(">> \(__FUNCTION__) \(peerID)")
        
        // Remove peer from discovered peers
        for (index, peer) in peers.enumerate() {
            if (peer.peerId.isEqual(peerID)) {
                peers.removeAtIndex(index)
                break
            }
        }
        
        // Inform delegate
        browserDelegate?.didLostPeer()
    }
    
}

// MARK: - MCSessionDelegate

extension SZDiscoveryManager: MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print(">> \(__FUNCTION__) \(peerID) \(state)")
        switch state{
        case .Connected:
            print(">> Connected to session!")
            if let peer = peerForPeerID(peerID) {
                peer.connected = true
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.sessionDelegate?.didConnectWithPeer(peer)
                })
            }
            
        case .Connecting:
            print(">> Connecting to session...")
            
        default:
            print(">> Did not connect to session!")
            if let peer = peerForPeerID(peerID) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.sessionDelegate?.didNotConnectWithPeer(peer)
                })
            }
        }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer
        peerID: MCPeerID, certificateHandler: (Bool) -> Void)
    {
        print(">> \(__FUNCTION__) \(peerID)")
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print(">> \(__FUNCTION__) \(peerID)")
        
        guard let peer = peerForPeerID(peerID) else { return }
        guard let message = String(data: data, encoding: NSUTF8StringEncoding) else { return }
        print("Message: \(message)")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            sessionDelegate?.didReceivedMessage(message, fromPeer: peer)
        })
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String,
        fromPeer peerID: MCPeerID)
    {
        print(">> \(__FUNCTION__) \(peerID)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer
        peerID: MCPeerID, withProgress progress: NSProgress)
    {
        print(">> \(__FUNCTION__) \(peerID)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer
        peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)
    {
        print(">> \(__FUNCTION__) \(peerID)")
    }
    
}