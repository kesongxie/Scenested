//
//  PostComment.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/21/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

class PostComment{
    var postCommentId: Int?
   // var commentUserId: Int?
    var commentText: String?
    var commentTime: String?
    weak var post: Post?
    var commentUser: User! //the user who commented the post, this should be load after the comment tableview is load
    
    //var mentionedUserIdList: [Int]?
    var mentionedUserList: [User]?

    
    init(postCommentId: Int, commentUser: User, commentTime: String, commentText: String, post: Post, mentionedUserList: [User]? = nil){
        self.postCommentId = postCommentId
        self.commentTime = commentTime
        self.commentText = commentText
        self.post = post
        self.commentUser = commentUser
        self.mentionedUserList = mentionedUserList
        
    }
 
    convenience init(commentInfo: [String: AnyObject]){
        let postCommentId = commentInfo["post_comment_id"] as! Int
        let commentTime = commentInfo["comment_time"] as! String
        let commentText =  commentInfo["comment_text"] as! String
        let post = commentInfo["post"] as! Post
        let commentUserInfo = commentInfo["commentUserInfo"] as! [String: AnyObject]
        let commentUser = User(userInfo: commentUserInfo)
        var mentionedUserList: [User]?
        if let userInfoList = commentInfo["mentionedUserInfoList"] as? [[String: AnyObject]]{
            if userInfoList.count > 0{
                mentionedUserList = [User]()
                for userInfo in userInfoList{
                    mentionedUserList?.append(User(userInfo: userInfo))
                }
            }
        }
        self.init(postCommentId: postCommentId, commentUser: commentUser, commentTime: commentTime, commentText: commentText, post: post, mentionedUserList: mentionedUserList)
    }

}

extension PostComment: Equatable{
}

func ==(lhs: PostComment, rhs: PostComment) -> Bool {
    return lhs.postCommentId == rhs.postCommentId
}


func !=(lhs: PostComment, rhs: PostComment) -> Bool {
    return lhs.postCommentId != rhs.postCommentId
}
