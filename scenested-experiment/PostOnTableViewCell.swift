//
//  PostOnTableViewCell.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/15/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class PostOnTableViewCell: UITableViewCell {

    @IBOutlet weak var featureImageView: UIImageView!{
        didSet{
            featureImageView.layer.cornerRadius = 4.0
            featureImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var featureNameLabel: UILabel!
    
    @IBOutlet weak var featureDetailLabel: UILabel!
    
    var feature: Feature?{
        didSet{
           updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(){
        if feature != nil{
            featureNameLabel?.text = feature!.featureName
            featureImageView?.loadImageWithUrl(feature!.coverPhoto.url)
            let postInFeatureCount = feature!.postCount
            featureDetailLabel?.text = String(postInFeatureCount) + " Post" + ((postInFeatureCount > 1) ? "s":"")
            
        }
    }

}
