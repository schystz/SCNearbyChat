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
    @IBOutlet weak var connectedIcon: UIImageView!
    
    var peer: SZPeer! {
        didSet {
            initial.text = peer.initial
            name.text = peer.name
            bio.text = peer.bio
            
            if (peer.connected) {
                connectedIcon.alpha = 1
            } else {
                connectedIcon.alpha = 0
            }
            
            initial.backgroundColor = SZHelper.colorForGender(peer.gender)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create a round background effect for initial label
        initial.textColor = UIColor.whiteColor()
        initial.layer.cornerRadius = 20
        initial.clipsToBounds = true
        
        // Connected icon tinted
        connectedIcon.image = UIImage(named: "icon_link")?.imageWithRenderingMode(.AlwaysTemplate)
        
        // Fonts
        initial.font = UIFont(name: "Roboto-Light", size: 24)
        name.font = UIFont(name: "Roboto", size: 17)
        bio.font = UIFont(name: "Roboto", size: 12)
    }

}