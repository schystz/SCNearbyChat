//
//  SZPeerCell.swift
//  SCNearbyChat
//
//  Created by James Russell Orola on 08/10/2015.
//  Copyright © 2015 schystz. All rights reserved.
//

import UIKit

class SZPeerCell: UITableViewCell {

    @IBOutlet weak var initial: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bio: UILabel!
    
    var peer: SZPeer? {
        didSet {
            initial.text = peer?.initial
            name.text = peer?.name
            bio.text = peer?.bio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create a round background effect for initial label
        initial.textColor = UIColor.whiteColor()
        initial.backgroundColor = UIColor.darkGrayColor()
        initial.layer.cornerRadius = 20
        initial.clipsToBounds = true
    }

}