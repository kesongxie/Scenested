//
//  NearByTableViewCell.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/24/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class NearByTableViewCell: UITableViewCell {
    
    
    var user: User?{
        didSet{
            
//            userAvatorImageView.image = UIImage(named: user!.avatorUrl)
//            
//            
//            userNameLabel.text = user?.fullname
//            userfeatureLabel.text = "Programming, Tennis"
        }
    }
    
    
    
    @IBOutlet weak var userAvatorImageView: UIImageView!{
        didSet{
            userAvatorImageView.layer.cornerRadius = userAvatorImageView.frame.size.width / 2
            userAvatorImageView.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userfeatureLabel: UILabel!
    
    
    @IBOutlet weak var followBtn: UIButton!{
        didSet{
            followBtn.becomeConnectButton()
        }
    }
    
    
    
    
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
