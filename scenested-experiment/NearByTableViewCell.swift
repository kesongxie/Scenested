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
            userNameLabel?.text = user?.fullname
            userAvatorImageView.loadImageWithUrl(user?.avator?.url)
            
            if let featureString = user?.getUserFeaturesAsString(){
                userfeatureLabel.text = featureString
            }else{
                userfeatureLabel.text = "NO FEATURE YET"
                userfeatureLabel.alpha = 0.6
            }
        }
    }
    
    
    @IBOutlet weak var userAvatorImageView: UIImageView!{
        didSet{
            userAvatorImageView.layer.cornerRadius = 24
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
