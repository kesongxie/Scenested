//
//  PostLike.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/18/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

class PostLike{
    var postLikeId: Int?
    var likeTime: String?
    var likeUserId: Int?
    var postId: Int?
    weak var post: Post?
    var likeUser: User! //the user who liked the post, this should be load when the likeTableview loads
    
    
    
    init(postLikedId: Int, postId: Int){
        self.postLikeId = postLikedId
        self.postId = postId
    }
    
    
    init(postLikeId: Int, likeTime: String, likeUserId: Int, post: Post){
        self.postLikeId = postLikeId
        self.likeTime = likeTime
        self.likeUserId = likeUserId
        self.post = post

    }
    
    
    convenience init(likeInfo: [String: AnyObject]){
        let postLikeId = likeInfo["post_like_id"] as! Int
        let likeTime = likeInfo["like_time"] as! String
        let likeUserId = likeInfo["liked_user_id"] as! Int
        let post = likeInfo["post"] as! Post
        self.init(postLikeId: postLikeId, likeTime: likeTime,likeUserId: likeUserId, post: post)
    }
}

extension PostLike: Equatable{
}

func ==(lhs: PostLike, rhs: PostLike) -> Bool {
    return lhs.postLikeId == rhs.postLikeId
}


func !=(lhs: PostLike, rhs: PostLike) -> Bool {
    return !(lhs == rhs)
}



