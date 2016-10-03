//
//  Feature.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/2/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

class Feature{
    let FetchPostForFeaturePath = HttpCallPath + "FetchPostForFeature.php"
    let DeletePostPath = HttpCallPath + "DeletePost.php"

    let id: Int
    let coverPhoto: Photo
    let featureName: String
    unowned let user: User
    var postCount: Int //this contains the total number of post
    var post: [[Post]]? //each element is a section, and a section contains an array of post, this contains the current loadded post
    var currentLoadedPostCount: Int = 0
    var currentNumberOfLoadedSection: Int = -1
    var lastLoadedPostId: Int? //this will updates everytime fetching posts
    
    //share a post
    static let SharePostTextKey = "postText"
    static let SharePostPhotoKey = "postPhoto"
    static let SharePostFeatureIdKey = "featureId"
    static let SharePostMediaKey = "postMedia"
    static let SharePostTextualInfoKey = "postTextualInfo"
    static let RangingSimilarFeaturePath = ServerRoot + "PushNotification/RangeSimilarFeature.php"

    

    
    init(id: Int, coverPhoto: Photo, featureName: String, user: User, postCount: Int){
        self.id = id
        self.coverPhoto = coverPhoto
        self.featureName = featureName
        self.user = user
        self.postCount = postCount
        //fetch the posts for this feature
        //fetchPostsForFeature(nil)
    }
    
    convenience init(featureInfo: [String: AnyObject]){
        let featureId = featureInfo["feature_id"] as! Int
        let coverInfo = featureInfo["photo"] as! [String: String]
        let coverPhoto = Photo(url: coverInfo["url"]!, hash: coverInfo["hash"]!)
        let featureName = featureInfo["name"] as! String
        let postCount = featureInfo["postCount"] as! Int
        let user = featureInfo["user"] as! User
        self.init(id: featureId, coverPhoto: coverPhoto, featureName: featureName, user: user, postCount: postCount)
    }
    
    
    private func resetPost(){
        self.post = nil
        self.currentNumberOfLoadedSection = -1
        self.currentLoadedPostCount = 0
        self.lastLoadedPostId = nil
    }
    
    //check whether there is new post to load
    internal func refreshPost(numberOfRequestedRow: Int, completionHandler:(Int? -> Void)? = nil){
        self.resetPost()
        fetchPostsForFeature(nil, numberOfRequestedRow: numberOfRequestedRow, completionHandler: completionHandler)
    }
    

    
    /*
         postIdOffset is the last loaded post's id, if it's nil, load from the beginning of the feature
         the numberOfRequestedRow is the number of maximum row the request should return, if it's nil, load all the post
     
    */
    internal func fetchPostsForFeature(postIdOffset: Int? = nil, numberOfRequestedRow: Int, completionHandler: (Int? -> Void)? = nil){
        var param: [String: AnyObject] = [
            "featureId": id
        ]
        if postIdOffset != nil{
            param["postIdOffset"] = postIdOffset
        }
        param["numberOfRequestedRow"] = numberOfRequestedRow
        
        HttpRequest.sendRequest(FetchPostForFeaturePath, method: .GET, param: param, completionHandler: {
            (response, error) in
            var lastRowPostId: Int?
            if response != nil{
                if let posts = response!["posts"] as? [[String: AnyObject]]{
                    lastRowPostId = response!["lastRowPostId"] as? Int;
                    if self.post == nil{
                        //this is the first load
                        self.post = [[Post]]()
                    }
                    self.post!.append([Post]())
                    self.currentNumberOfLoadedSection += 1
                    for postInfo in posts{
                        var postInfo = postInfo
                        postInfo["feature"] = self
                        let post = Post(postInfo: postInfo)
                         self.post![self.currentNumberOfLoadedSection].append(post) //append new loaded post to a specific section
                        self.currentLoadedPostCount += 1
                    }
                }
            }
            if completionHandler != nil{
                completionHandler!(lastRowPostId)
            }
        })
    
    }
    
    internal func sharePost(postInfo: [String: AnyObject]?, completionHandler: (response: Post?, error: AddPostError) -> Void ){
        if let postInfo = postInfo{
            let images = postInfo[Feature.SharePostMediaKey] as? [String: UIImage]
            
            var textualInfo = [String: AnyObject]()
            textualInfo["userId"] = self.user.id
            if let additionalTextualInfo = postInfo[Feature.SharePostTextualInfoKey] as? [String: AnyObject]{
                textualInfo.addDictionaryToCurrent(additionalTextualInfo)
            }
            
            HttpRequest.uploadImagesWithUserInfo(User.SharePostPath ,images: images, param: textualInfo, completionHandler: {
                (response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil && response != nil{
                        if let errorCode = response!["errorCode"] as? Int {
                            if errorCode == 0{
                                //successfully adding the post
                                if let postInfo = response!["post"] as? [String: AnyObject]{
                                    var postInfo = postInfo
                                    postInfo["feature"] = self
                                    let addedPost = Post(postInfo: postInfo)
                                    
                                    //add a section
                                    if self.post == nil{
                                        //there is no section yet, which means the post haven't been loaded yet
                                        self.post = [[Post]]()
                                        self.post!.append([addedPost])
                                    }else{
                                        self.post![0].insert(addedPost, atIndex: 0)
                                    }
                                    
                                    self.currentLoadedPostCount += 1
                                    //append new loaded post to a specific section
                                    self.postCount = response!["postCountInFeature"] as! Int
                                    completionHandler(response: addedPost, error: AddPostError.None)
                                }
                            }else{
                                if errorCode == 1{
                                    completionHandler(response: nil, error: AddPostError.MissingPhoto(alertTitle: "Missing photo for post", alertBody: "Please add a photo for your post"))
                                }else{
                                    completionHandler(response: nil, error: AddPostError.UnKnown(alertTitle: "Failed to share post", alertBody: "Please check your internet connection or Wifi settings"))
                                }
                            }
                        }
                    }else{
                        print(error)
                    }
                })
            })
        }
    }
    
    internal func deletePost(post: Post, userId: Int, completionHandler: (Bool) -> Void){
        let postId = post.id
        let param: [String: AnyObject] = [
            "postId": postId,
            "userId": userId,
            "featureId": self.id
        ]
        HttpRequest.sendRequest(DeletePostPath, method: .POST, param: param, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil && response != nil{
                    if let status = response!["status"] as? Bool{
                        if status{
                            self.postCount = response!["postCountInFeature"] as! Int
                        }
                        completionHandler(status)
                    }
                }else{
                    print(error)
                    completionHandler(false)
                }
            })
        })
    }
    
    
    //before any post is loaded use the initial postCount value, after post is loadded, use the size of the array as the post count
    internal func getCurrentLoadedPostCount() -> Int{
        return self.post?.count ?? 0
    }
    
    internal func getTotalPostCount() -> Int{
        return self.postCount
    }

    
    internal static func rangingSimilarFeatureBetweenUsersById(userRequestId requestUserId: Int, userComeAcrossId comeAcrossUserId: Int){
        //this is the parameter that needs to pass in
        print("ranging similar feature starts")
        
        
        let param: [String: AnyObject] = [
           "request_user_id": requestUserId,
           "come_across_user_id": comeAcrossUserId
        ]
        HttpRequest.sendRequest(Feature.RangingSimilarFeaturePath, method: .GET, param: param, completionHandler: {
            (response, error) in
            print(response)
        })
        
        
    }

    
}
