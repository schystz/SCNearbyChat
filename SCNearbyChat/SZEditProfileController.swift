//
//  SZEditProfileController.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 08/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

class SZEditProfileController: UITableViewController {
    
    // MARK: - Properties

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderField: UISegmentedControl!
    @IBOutlet weak var bioField: UITextField!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = SZUser.sharedInstance
        nameField.text = user.username
        genderField.selectedSegmentIndex = user.gender.rawValue
        bioField.text = user.bio
        
        nameField.delegate = self
        bioField.delegate = self
    }
    
    // MARK: - Actions

    @IBAction func save(sender: AnyObject) {
        let user = SZUser.sharedInstance
        user.username = nameField.text!
        user.gender = Gender(rawValue: genderField.selectedSegmentIndex)!
        user.bio = bioField.text!
        user.saveProfile()
        
        SZDiscoveryManager.sharedInstance.refreshAdvertisingInfo()
        
        SVProgressHUD.showSuccessWithStatus("Profile updated!")
        navigationController?.popViewControllerAnimated(true)
    }
    
}

// MARK: - UITextFieldDelegate

extension SZEditProfileController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.isEqual(nameField)) {
            bioField.becomeFirstResponder()
        } else {
            save(textField)
        }
        
        return true
    }
    
}
