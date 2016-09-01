//
//  postTableViewCell.swift
//  poststed-experiment
//
//  Created by Xie kesong on 7/21/16.
//  Copyright © 2016 ___poststed___. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var postUserImageView: UIImageView!{
        didSet{
            postUserImageView.layer.cornerRadius = 22
            postUserImageView.clipsToBounds = true

            
        }
    }
    
    @IBOutlet weak var postUserNameLabel: UILabel!
    
    @IBOutlet weak var postPictureImageView: UIImageView!
    
    @IBOutlet weak var postPictureHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postTime: UILabel!
    
    
    @IBOutlet weak var featureNameLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var postLikeHeartImageView: UIImageView!{
        didSet{
            postLikeHeartImageView.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleLike(_:)))
            postLikeHeartImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var postLikeCountLabel: UILabel!
    
    @IBOutlet weak var dotIconImageView: UIImageView!
    
    @IBOutlet weak var commentIconImageView: UIImageView!
    
    
    @IBOutlet weak var postCommentCountLabel: UILabel!
    
    enum PostLikeStatus{
        case Liked(PostLike)
        case NotLiked
    }
    var post: Post?{
        didSet{
            if post != nil{
                updateUI()
            }
        }
    }
    var isUserLikeThisPost: PostLikeStatus?{
        didSet{
            switch isUserLikeThisPost!{
            case .Liked(_):
                setActiveLikePostStatusUI(postLikeHeartImageView, likeCountLabel: postLikeCountLabel)
            case .NotLiked:
                setDeActiveLikePostStatusUI(postLikeHeartImageView, likeCountLabel: postLikeCountLabel)
            }
        }
    }
    
    
    func updateUI(){
        postUserImageView?.image = nil
        postUserNameLabel?.text = nil
        postPictureImageView?.image = nil
        postTime?.text = nil
        featureNameLabel?.text = nil
        descriptionTextView?.text = nil
        
        if let userAvator = post!.feature.user.avator{
            postUserImageView.loadImageWithUrl(userAvator.url, imageUrlHash: userAvator.hash, cacheType: CacheType.CacheForProfileAvator)
            
        }
        
        if let postImages = post?.photo?.first{
            postPictureImageView.loadImageWithUrl(postImages.url, imageUrlHash: postImages.hash, cacheType: CacheType.CacheForPostPhoto)
            postPictureImageView.frame.size.width = UIScreen.mainScreen().bounds.size.width
            postPictureHeightConstraint.constant =  postPictureImageView.frame.size.width / postImages.aspectRatio!
        }
        postUserNameLabel?.text = post!.feature.user.fullname
        featureNameLabel?.text = post!.feature.featureName
        
        descriptionTextView.setStyleText(post!.postText)

        let loggedUserId = getLoggedInUser()?.id
        let postUserId = post?.feature.user.id
        if  (loggedUserId == nil || postUserId == nil) ||   loggedUserId! != postUserId!{
            dotIconImageView.hidden = true
        }
        self.updateLikeCountUI()

        //check whether the user has like the post or not, and style it correpsondingly
        let (like, postLike) =  getLoggedInUser()!.doesUserLikeThisPost(post!.id)
        
        if like && postLike != nil{
            isUserLikeThisPost = PostLikeStatus.Liked(postLike!)
        }else{
            isUserLikeThisPost = PostLikeStatus.NotLiked
        }
        
        //configure the comment
        let commentCount =  post?.postCommentCount ?? 0
        if commentCount < 1{
            postCommentCountLabel.text = ""
        }else{
            postCommentCountLabel.text = String(commentCount)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func updateLikeCountUI(){
        let likeCount =  post?.postLikeCount ?? 0
        if likeCount < 1{
            self.postLikeCountLabel.text = ""
        }else{
            self.postLikeCountLabel.text = String(likeCount)
        }

    }
    
    func toggleLike(gesture: UITapGestureRecognizer){
        postLikeHeartImageView.userInteractionEnabled = false
        switch isUserLikeThisPost!{
        case .Liked(let postLike):
          //  cancel the like
            getLoggedInUser()?.toggleLikePost(post!, postLike: postLike, completionHandler:{
                postLike in
                if postLike == nil{
                    self.isUserLikeThisPost = PostLikeStatus.NotLiked
                    self.updateLikeCountUI()
                    setDeActiveLikePostStatusUI(self.postLikeHeartImageView, likeCountLabel: self.postLikeCountLabel)
                    self.postLikeHeartImageView.userInteractionEnabled = true

                }
            })
        case .NotLiked:
            getLoggedInUser()?.toggleLikePost(post!, postLike: nil, completionHandler:{
                postLike in
                if postLike != nil{
                    self.isUserLikeThisPost = PostLikeStatus.Liked(postLike!)
                    self.updateLikeCountUI()
                    setActiveLikePostStatusUI(self.postLikeHeartImageView, likeCountLabel: self.postLikeCountLabel)
                    self.postLikeHeartImageView.userInteractionEnabled = true
                }
            })
        }
    }
}
