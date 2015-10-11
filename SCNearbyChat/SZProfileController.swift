//
//  SZProfileController.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 07/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

class SZProfileController: UITableViewController {
    
    // MARK: - Properties

    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateLabels()
        customizeUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didUpdateProfile"),
            name: "UserProfileUpdated", object: nil)
    }
    
    // MARK: - Private Methods
    
    private func populateLabels() {
        let user = SZUser.sharedInstance
        nameLabel.text = user.username
        genderLabel.text = user.gender.description
        bioLabel.text = user.bio
        initialLabel.text = user.initials()
        visibilitySwitch.on = user.visibleToOthers
        
        initialLabel.backgroundColor = SZHelper.colorForGender(user.gender)
    }
    
    private func customizeUI() {
        // Create a round background effect for initial label
        initialLabel.textColor = UIColor.whiteColor()
        initialLabel.layer.cornerRadius = 35
        initialLabel.clipsToBounds = true
        
        // Customize button
        editButton.backgroundColor = GlobalTintColor
        editButton.tintColor = UIColor.whiteColor()
        editButton.layer.cornerRadius = 13
        
        // Fonts
        initialLabel.font = UIFont(name: "Roboto-Light", size: 36)
        nameLabel.font = UIFont(name: "Roboto-Light", size: 20)
        bioLabel.font = UIFont(name: "Roboto-Light", size: 17)
        editButton.titleLabel?.font = UIFont(name: "Roboto", size: 12)
    }
    
    // MARK: - Public Methods
    
    func didUpdateProfile() {
        populateLabels()
    }
    
    // MARK: - Actions
    
    @IBAction func didSwitchVisibility(sender: AnyObject) {
        SZUser.sharedInstance.visibleToOthers = visibilitySwitch.on
        SZUser.sharedInstance.saveVisibility()
        
        if (visibilitySwitch.on) {
            SZDiscoveryManager.sharedInstance.advertiser.startAdvertisingPeer()
        } else {
            SZDiscoveryManager.sharedInstance.advertiser.stopAdvertisingPeer()
        }
    }

}
