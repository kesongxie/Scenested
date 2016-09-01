//
//  Scene.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/5/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

class Post{
    let id: Int
    var photo: [PostPhoto]?
    let postText: String
    let postTime: String
    unowned let feature: Feature
    
    var postLikeCount: Int //the total number of post like
    var postLikes: [PostLike]? //the current loaded post like
    var postCommentCount: Int //the total number of post comment
    var postComments: [PostComment]? //the current loaded post comment
    
    var mentionedUserList: [User]?
    
    let GetFreshPostLikesPath = HttpCallPath + "FetchFreshPostLike.php"
    let GetFreshPostCommentsPath = HttpCallPath + "FetchFreshPostComments.php"
    let DeleteCommentPath = HttpCallPath + "DeleteComment.php"
    
    init(id: Int, postText: String, postTime: String, feature: Feature, photo: [PostPhoto]?, postLikeCount: Int, postCommentCount: Int,  mentionedUserList: [User]?){
        self.id = id
        self.postText = postText
        self.postTime = postTime
        self.photo = photo
        self.feature = feature
        self.postLikeCount = postLikeCount
        self.postCommentCount = postCommentCount
        self.mentionedUserList = mentionedUserList
    }
    
    
    
    convenience init(postInfo: [String: AnyObject]){
        let postId = postInfo["post_id"] as! Int
        let multiplePhotoInfo = postInfo["postPhoto"] as! [[String: AnyObject]]
        var photos: [PostPhoto]?
        if multiplePhotoInfo.count > 0{
            photos = [PostPhoto]()
            for photoInfo in multiplePhotoInfo{
                let url = photoInfo["url"] as! String
                let hash = photoInfo["hash"] as! String
                let aspectRatio = photoInfo["aspectRatio"] as! CGFloat
                photos?.append(PostPhoto(url: url, hash: hash, aspectRatio: aspectRatio))
            }
        }
        let postText = postInfo["text"] as! String
        let postTime = postInfo["created_time"] as! String
        let fearture = postInfo["feature"] as! Feature
        let postLikeCount = postInfo["postLikeCount"] as! Int
        let postCommentCount = postInfo["postCommentCount"] as! Int
        var mentionedUserList: [User]?
        if let userInfoList = postInfo["mentionedUserInfoList"] as? [[String: AnyObject]]{
            if userInfoList.count > 0{
                mentionedUserList = [User]()
                for userInfo in userInfoList{
                    mentionedUserList?.append(User(userInfo: userInfo))
                }
            }
        }
        self.init(id: postId, postText: postText, postTime: postTime, feature: fearture, photo:photos,  postLikeCount: postLikeCount, postCommentCount: postCommentCount,  mentionedUserList: mentionedUserList)
    
    }

    
    
    func getPostLikeCount() -> Int{
        return postLikes?.count ?? 0
    }
    
    
    //fetch the user information for post likes
    internal func fetchPostLikeInfo(completionHandler: (response: [PostLike]?, error: String?) -> Void){
        let param = [
            "postId": self.id
        ]
        self.postLikes = nil
        HttpRequest.sendRequest(GetFreshPostLikesPath, method: .GET, param: param, completionHandler: {
            response, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let multiplePostLikeInfo = response as? [[String: AnyObject]]{
                    var postLikes: [PostLike]?
                    if multiplePostLikeInfo.count > 0{
                        postLikes = [PostLike]()
                        for likeInfo in multiplePostLikeInfo{
                            var likeInfo = likeInfo
                            likeInfo["post"] = self
                            let postLike = PostLike(likeInfo: likeInfo)
                            postLikes?.append(postLike)
                        }
                        self.postLikes = postLikes
                    }
                    completionHandler(response: postLikes, error: error)
                }
            })
        })
    }
    
    internal func fetchPostCommentInfo(completionHandler: (response: [PostComment]?, error: String?) -> Void){
        let param = [
            "postId": self.id
        ]
        self.postComments = nil
        HttpRequest.sendRequest(GetFreshPostCommentsPath, method: .GET, param: param, completionHandler: {
            response, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let multiplePostCommentInfo = response as? [[String: AnyObject]]{
                    var postComments: [PostComment]?
                    if multiplePostCommentInfo.count > 0{
                        postComments = [PostComment]()
                        for commentInfo in multiplePostCommentInfo{
                            var commentInfo = commentInfo
                            commentInfo["post"] = self
                            let postComment = PostComment(commentInfo: commentInfo)
                            postComments?.append(postComment)
                        }
                        self.postComments = postComments
                    }
                    completionHandler(response: postComments, error: error)
                }
            })
        })

    }
    
    
    
    
    
    internal func deleteComment(commentId: Int, completionHandler: (deletedSucceed: Bool) -> Void){
        let param = [
            "commentId": commentId
        ]
        HttpRequest.sendRequest(DeleteCommentPath, method: .GET, param: param, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if let deletedSucceed = response as? Bool{
                    completionHandler(deletedSucceed: deletedSucceed)
                }else{
                    completionHandler(deletedSucceed: false)
                }

            })
            
        })
    }
    
    
    
    

}
