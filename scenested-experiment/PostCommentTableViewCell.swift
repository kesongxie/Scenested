//
//  PostCommentTableViewCell.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/22/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class PostCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentUserImageView: UIImageView!{
        didSet{
            commentUserImageView.layer.cornerRadius = commentUserImageView.frame.size.width / 2
            commentUserImageView.clipsToBounds = true
        }
    }
   
    
    @IBOutlet weak var fullname: UILabel!
    
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var commentText: UITextView!
    
    var comment: PostComment?{
        didSet{
            updateUI()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func updateUI(){
        if let postComment = comment{
            commentUserImageView?.loadImageWithUrl(postComment.commentUser.avator?.url, imageUrlHash: postComment.commentUser.avator?.hash, cacheType: CacheType.CacheForProfileAvator)
            fullname?.text = postComment.commentUser.fullname
            time?.text =  convertDateStringToElapseTime(postComment.commentTime)?.uppercaseString
            commentText?.setStyleText(postComment.commentText!)
        }
    }
    

    
    
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
