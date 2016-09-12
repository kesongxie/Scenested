//
//  PostLikeTableViewCell.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/18/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class PostLikeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var likeUserAvatorImageView: UIImageView!{
        didSet{
            likeUserAvatorImageView.layer.cornerRadius = 22.0
            likeUserAvatorImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var likeUserFullNameLabel: UILabel!
    
    
    @IBOutlet weak var likedTime: UILabel!
    
    @IBOutlet weak var userFeatureStringLabel: UILabel!
    
    var postLike: PostLike?{
        didSet{
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

 
    func updateUI(){
        if let postLike = postLike{
            likeUserAvatorImageView?.loadImageWithUrl(postLike.likeUser?.avator?.url)
            likeUserFullNameLabel?.text = postLike.likeUser?.fullname
            likedTime?.text = convertDateStringToElapseTime(postLike.likeTime)?.uppercaseString
            
            let likeUserFeatureString = postLike.likeUser?.getUserFeaturesAsString() ?? ""
            if !likeUserFeatureString.isEmpty{
                userFeatureStringLabel?.text = likeUserFeatureString
            }else{
                userFeatureStringLabel?.text = "NO FEATURE YET"
                userFeatureStringLabel.alpha = 0.6
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
