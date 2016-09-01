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
    var postId: Int?
    weak var post: Post?
    var likeUser: User!
    
    
    
    //lazy loading, only gather necessary information for the post like
    init(postLikedId: Int, postId: Int){
        self.postLikeId = postLikedId
        self.postId = postId
    }
    
    
    init(postLikeId: Int, likeTime: String, post: Post, likeUser: User){
        self.postLikeId = postLikeId
        self.likeTime = likeTime
        self.post = post
        self.postId = self.post?.id
        self.likeUser = likeUser

    }
    
    
    convenience init(likeInfo: [String: AnyObject]){
        let postLikeId = likeInfo["post_like_id"] as! Int
        let likeTime = likeInfo["like_time"] as! String
        let post = likeInfo["post"] as! Post
        //initialize the like user
        let likeUserInfo = likeInfo["likeUserInfo"] as! [String: AnyObject]
        let user = User(userInfo: likeUserInfo)
        self.init(postLikeId: postLikeId, likeTime: likeTime, post: post, likeUser: user)
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


