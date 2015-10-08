//
//  SZDiscoverController.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SZDiscoverController: UITableViewController {
    
    // MARK: - Properties

    @IBOutlet weak var statusLabel: UILabel!
    
    var selectedPeer: SZPeer?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SZDiscoveryManager.sharedInstance.delegate = self
        updateStatusLabel()
        
        // rowHeight might not work for iOS 8.0 so we wrap it in a condition
        if (tableView.respondsToSelector(Selector("rowHeight"))) {
            tableView.rowHeight = 60
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowChatController") {
            if let peer = selectedPeer {
                let controller = segue.destinationViewController as! SZChatController
                controller.hidesBottomBarWhenPushed = true
                controller.peer = peer
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateStatusLabel() {
        if (SZDiscoveryManager.sharedInstance.peers.count == 1) {
            statusLabel.text = "There is 1 other user nearby"
        } else if (SZDiscoveryManager.sharedInstance.peers.count > 1) {
            statusLabel.text = "There are \(SZDiscoveryManager.sharedInstance.peers.count) users nearby"
        } else {
            statusLabel.text = "You are the only one here"
        }
    }

    // MARK: - Table view data source / delegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SZDiscoveryManager.sharedInstance.peers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SZPeerCell", forIndexPath: indexPath) as! SZPeerCell
        cell.peer = SZDiscoveryManager.sharedInstance.peers[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPeer = SZDiscoveryManager.sharedInstance.peers[indexPath.row]
        performSegueWithIdentifier("ShowChatController", sender: self)
    }

}

extension SZDiscoverController: SZDiscoveryManagerDelegate {
    
    // MARK: - SZDiscoveryManagerDelegate
    
    func didFoundPeer() {
        tableView.reloadData()
        updateStatusLabel()
    }
    
    func didLostPeer() {
        tableView.reloadData()
        updateStatusLabel()
    }
    
    func didReceivedInvitationFromPeer(peerId: MCPeerID) {
        
    }
    
    func didConnectWithPeer(peerId: MCPeerID) {
        
    }
    
}