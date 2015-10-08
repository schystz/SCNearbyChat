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
    
    let systemSenderId = "XXX"
    var peer: SZPeer!
    var messages = [JSQMessage]()
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var systemBubbleImage: JSQMessagesBubbleImage!
    var outgoingAvatarImage: JSQMessagesAvatarImage!
    var incomingAvatarImage: JSQMessagesAvatarImage!
    var systemAvatarImage: JSQMessagesAvatarImage!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "randomstring"
        senderDisplayName = SZUser.sharedInstance.initials()
        
        // Initial system message
        let message = JSQMessage(senderId: systemSenderId, senderDisplayName: "S", date: NSDate(), text: "A chat request is sent to \(peer.name). Please wait until the other party has accepted your request.")
        messages.append(message)
        sendChatRequest()
        
        customizeUI()
    }
    
    // MARK: - Private Methods
    
    private func customizeUI() {
        // Disable textinput on the input bar by default
        // Enable it once the other party accepted the chat request
        inputToolbar?.contentView?.textView?.editable = false
        
        // Hide attachment button on input bar
        inputToolbar?.contentView?.leftBarButtonItem = nil
        
        // Initialize chat bubble images
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        incomingBubbleImage = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        systemBubbleImage = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        // Initialize avatar images
        outgoingAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(SZUser.sharedInstance.initials(), backgroundColor: UIColor.darkGrayColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        incomingAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(peer.initial, backgroundColor: UIColor.darkGrayColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        systemAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("S", backgroundColor: UIColor.blueColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    }
    
    private func sendChatRequest() {
        // For security purposes, before starting the chat session, other party's approval is required
        let discoveryManager = SZDiscoveryManager.sharedInstance
        discoveryManager.browser.invitePeer(peer.peerId, toSession: discoveryManager.session,
            withContext: nil, timeout: 10)
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!)
    {
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messages.append(message)
        
        finishSendingMessageAnimated(true)
    }

}

// MARK: - UICollectionView DataSource

extension SZChatController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if (!message.isMediaMessage) {
            if (message.senderId == senderId) {
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
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.item]
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
        let message = messages[indexPath.item]
        if (message.senderId == systemSenderId) {
            return systemAvatarImage
        } else if (message.senderId == senderId) {
            return outgoingAvatarImage
        } else {
            return incomingAvatarImage
        }
    }
    
}
