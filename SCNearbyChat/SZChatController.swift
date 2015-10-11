//
//  SZChatController.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 08/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

class SZChatController: JSQMessagesViewController {
    
    // MARK: - Properties
    
    var peer: SZPeer!
    var requestedToChat = false
    
    private let systemSenderId = "XXX"
    private let systemSenderName = "S"
    
    private var outgoingBubbleImage: JSQMessagesBubbleImage!
    private var incomingBubbleImage: JSQMessagesBubbleImage!
    private var systemBubbleImage: JSQMessagesBubbleImage!
    private var outgoingAvatarImage: JSQMessagesAvatarImage!
    private var incomingAvatarImage: JSQMessagesAvatarImage!
    private var systemAvatarImage: JSQMessagesAvatarImage!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "randomstring"
        senderDisplayName = SZUser.sharedInstance.initials()
        SZDiscoveryManager.sharedInstance.sessionDelegate = self
        
        if (!peer.connected) {
            // Initial system message if not connected yet
            var text: String!
            if (requestedToChat) {
                text = "A chat request is sent to \(peer.name). Please wait until the other party has accepted your request."
                
                // Send invite to peer
                sendChatRequest()
            } else {
                text = "Starting chat session with \(peer.name)..."
            }
            
            let message = JSQMessage(senderId: systemSenderId, senderDisplayName: systemSenderName,
                date: NSDate(), text: text)
            peer.chatMessages.append(message)
            
            // Disable textinput on the input bar until request has been accepted
            enableInputToolbar(false)
        } else {
            // What now?
        }
        
        customizeUI()
    }
    
    // MARK: - Private Methods
    
    private func customizeUI() {
        // Hide attachment button on input bar
        inputToolbar?.contentView?.leftBarButtonItem = nil
        
        inputToolbar?.contentView?.rightBarButtonItem?.tintColor = GlobalTintColor
        
        // Initialize chat bubble images
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        incomingBubbleImage = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        systemBubbleImage = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        // Initialize avatar images
        outgoingAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(SZUser.sharedInstance.initials(), backgroundColor: SZHelper.colorForGender(SZUser.sharedInstance.gender), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        incomingAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(peer.initial, backgroundColor: SZHelper.colorForGender(peer.gender), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        systemAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(systemSenderName, backgroundColor: GlobalTintColor, textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
    
    private func sendChatRequest() {
        // For security purposes, before starting the chat session, other party's approval is required
        let discoveryManager = SZDiscoveryManager.sharedInstance
        discoveryManager.browser.invitePeer(peer.peerId, toSession: discoveryManager.session,
            withContext: nil, timeout: 10)
    }
    
    private func enableInputToolbar(enabled: Bool) {
        if (enabled) {
            inputToolbar?.contentView?.textView?.editable = true
            inputToolbar?.contentView?.textView?.alpha = 1
            inputToolbar?.contentView?.rightBarButtonItem?.enabled = true
        } else {
            inputToolbar?.contentView?.textView?.editable = false
            inputToolbar?.contentView?.textView?.alpha = 0.5
            inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
        }
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!)
    {
        // Send message to other part
        SZDiscoveryManager.sharedInstance.sendMessage(text, toPeer: peer)
        
        // Play "sent" sound
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        
        // Append message to the collection view & reload
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        peer.chatMessages.append(message)
        finishSendingMessageAnimated(true)
    }

}

// MARK: - UICollectionView DataSource

extension SZChatController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peer.chatMessages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = peer.chatMessages[indexPath.item]
        if (!message.isMediaMessage) {
            if (message.senderId == systemSenderId) {
                cell.textView?.textColor = UIColor.blackColor()
            } else {
                cell.textView?.textColor = UIColor.whiteColor()
            }
        }
        
        return cell
    }
    
}

// MARK: - JSQMessagesCollectionViewDataSource

extension SZChatController  {
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return peer.chatMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = peer.chatMessages[indexPath.item]
        if (message.senderId == systemSenderId) {
            return systemBubbleImage
        } else if (message.senderId == senderId) {
            return outgoingBubbleImage
        } else {
            return incomingBubbleImage
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        let message = peer.chatMessages[indexPath.item]
        if (message.senderId == systemSenderId) {
            return systemAvatarImage
        } else if (message.senderId == senderId) {
            return outgoingAvatarImage
        } else {
            return incomingAvatarImage
        }
    }
    
}

// MARK: - SZDiscoveryManagerSessionDelegate

extension SZChatController: SZDiscoveryManagerSessionDelegate {
    
    func didConnectWithPeer(peer: SZPeer) {
        // Play "received" sound
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        // Append message to the collection view & reload
        var text: String!
        if (requestedToChat) {
            text = "\(peer.name) has accepted your chat request."
        } else {
            text = "Connected with \(peer.name)"
        }
        
        let messageObject = JSQMessage(senderId: systemSenderId, senderDisplayName: systemSenderName,
            date: NSDate(), text: text)
        peer.chatMessages.append(messageObject)
        finishReceivingMessageAnimated(true)
        
        // Re-enable text input
        enableInputToolbar(true)
    }
    
    func didNotConnectWithPeer(peer: SZPeer) {
        // Play "received" sound
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        // Append message to the collection view & reload
        var text: String!
        if (requestedToChat) {
            text = "\(peer.name) has denied your chat request."
        } else {
            text = "Failed connecting to \(peer.name)"
        }
        
        let messageObject = JSQMessage(senderId: systemSenderId, senderDisplayName: systemSenderName,
            date: NSDate(), text: text)
        peer.chatMessages.append(messageObject)
        finishReceivingMessageAnimated(true)
        
        // Disable text input
        enableInputToolbar(false)
    }
    
    func didReceivedMessage(message: String, fromPeer peer: SZPeer) {
        // Play "received" sound
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        // Append message to the collection view & reload
        let messageObject = JSQMessage(senderId: peer.name, senderDisplayName: peer.initial, date: NSDate(), text: message)
        peer.chatMessages.append(messageObject)
        finishReceivingMessageAnimated(true)
    }
    
}
