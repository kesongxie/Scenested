//
//  User.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/24/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

class User{
    var id: Int?
    var username: String?
    var fullname: String?
    var avator: Photo?
    var cover: Photo?
    var bio: String?
    var features: [Feature]?
    var profileVisible: Bool = false
    var postLikes: [PostLike]?
    var bioMentionedUser:[User]?
    
    static let RegisterUserPath = HttpCallPath + "RegisterUser.php"
    static let LoginUserPath = HttpCallPath + "Login.php"
    static let EditProfilePath = HttpCallPath + "EditProfile.php"
    static let AddFeaturePath = HttpCallPath + "AddFeature.php"
    static let UserForEmailExistsPath = HttpCallPath + "UserForEmailExists.php"
    static let UserForUserNameExistsPath = HttpCallPath + "UserForUserNameExists.php"
    static let GetFeatureForUserPath = HttpCallPath + "GetFeatureForUser.php"
    static let SharePostPath = HttpCallPath + "SharePost.php"
    static let DeleteFeaturePath = HttpCallPath + "DeleteFeature.php"
    static let ToggleLikePostPath = HttpCallPath + "ToggleLikePost.php"
    static let CommentPostPath = HttpCallPath + "CommentPost.php"
    static let ReplyPostCommentPath = HttpCallPath + "ReplyPostComment.php"

    

    static let UserAuthenticationByEmailPasswordPath = HttpCallPath + "UserAuthenticationByEmailPassword.php"
    static let UserAuthenticationByUsernamePasswordPath = HttpCallPath + "UserAuthenticationByUsernamePassword.php"
    static let UserAuthenticationByUserIdPasswordPath = HttpCallPath + "UserAuthenticationByUserIdPassword.php"

    static let loginSucceedStatusCode = 200
    static let registeredSucceedStatusCode = 200
    static let registeredFailedStatusCode = 500
    static let loginFailedStatusCode = 500

    //Profile Edit Field Key
    static let EditProfileCoverKey = "profileCover"
    static let EditProfileAvatorKey = "profileAvator"
    static let EditProfileFullNameKey = "profileFullName"
    static let EditProfileBioKey = "proifleBio"
    static let EditProfileRangeVisibleKey = "profileVisible"
    static let EditProfileMediaKey = "profileMedia"
    static let EditProfileUserTextualInfoKey = "profileTextualInfo"
    
    //adding feature key
    static let AddFeatureNameKey = "featureName"
    static let AddFeaturePhotoKey = "featureCover"
    static let AddFeatureMediaKey = "featureMedia"
    static let AddFeatureTextualInfoKey = "featureTextualInfo"
    
       
    
    enum authenticationError{
        case IncorrectPassword(title: String, body: String) //title and body for AlertViewController
        case NoInternetConnection(title: String, body: String)
        case Unknown(title: String, body: String)
    }
    
    

    //initialize a user by the id
    init?(id: Int, completionHandler: (fetchingSucceed: Bool, respondInfo: AnyObject?) -> Void){
        //fetch necessary info for the user with this user id
        fetchUserInfoById(FetchUserInfoPath, id: id, callBack: {
            respondData in
            dispatch_async(dispatch_get_main_queue(), {
                if (respondData["statusCode"] as! Int) == 200 {
                    if let userInfo = respondData["info"] as? [String: AnyObject]{
                        //set up general info
                        self.setUserGeneralInfoByUserInfo(userInfo)
                        self.setAdditionalInfoByUserInfo(userInfo)
                        completionHandler(fetchingSucceed: true, respondInfo: userInfo)
                    }else{
                        completionHandler(fetchingSucceed: false, respondInfo: nil)
                    }
                }
            })
        })
    }
    
    
    
    //this initializer should be called only after successfully registering user
    init?(id: Int, username: String, afterRegisteredCompletionHandler: (succeedLogin: Bool) -> Void){
            dispatch_async(dispatch_get_main_queue(), {
            //fetch necessary info for the user with this user id
                self.id = id
                self.username = username
                afterRegisteredCompletionHandler(succeedLogin: true)
            })
    }

    
    init(userInfo: [String: AnyObject]){
        setUserGeneralInfoByUserInfo(userInfo)
        setAdditionalInfoByUserInfo(userInfo)
    }
    
    internal func setUserGeneralInfoByUserInfo(info: [String: AnyObject]?){
        if let info = info{
            self.id = (info["user_id"] as! Int)
            self.username = (info["username"] as! String)
            self.fullname = (info["fullname"] as! String)
            if let avatorInfo = info["avator"] as? [String: String ]{
                self.avator = Photo(url: avatorInfo["url"]!, hash: avatorInfo["hash"]!)
            }
            if let coverInfo = info["cover"] as? [String: String ]{
                self.cover = Photo(url: coverInfo["url"]!, hash: coverInfo["hash"]!)
            }
            self.bio = (info["bio"] as! String)
            self.profileVisible = ((info["profileVisible"] as! String) == "1")
        }
    }
    
    
    internal func setAdditionalInfoByUserInfo(userInfo: [String: AnyObject]){
        if let postLikes = userInfo["postLike"] as? [[String: AnyObject]]{
            if postLikes.count > 0{
                self.postLikes = [PostLike]()
                for postLike in postLikes{
                    let postId = postLike["post_id"] as! Int
                    let postLikeId = postLike["post_like_id"] as! Int
                    let like = PostLike(postLikedId: postLikeId, postId: postId)
                    self.postLikes?.append(like)
                }
            }
        }
        //set up features for the user
        if let features = userInfo["profileFeature"] as? [[String: AnyObject]]{
            self.features = [Feature]()
            for featureInfo in features{
                var featureInfo = featureInfo
                featureInfo["user"] = self
                let feature = Feature(featureInfo: featureInfo)
                self.features!.append(feature)
            }
        }
        
    }
    

    
    
    
    //called after profile updated
    internal func updateLoggedInUserWithInfoAfterUpdatingProfile(info: [String: AnyObject]?){
        if let info = info{
            setUserGeneralInfoByUserInfo(info)
        }
    }
    
    
    
    
//    deinit{
//        print("user get cleared")
//    }
    
    /*
        register a user
        return it's not nil when it failed, and it turns any error that occured
     */
    internal static func register(mediaInfo registerMediaInfo: [String: UIImage]?, textualInfo registerTextualInfo: [String: AnyObject], completionHandler: (registeredSucceed: Bool, registeredUserInfo: [String: AnyObject]?) -> (Void) ) -> String? {
        //check whether the username is null
        guard let username = registerTextualInfo[UserRegistrationLocalizedString.InfoUsernameKey] as? String else{
            return UserRegistrationLocalizedString.NullUsernameError
        }

        //check whether the username is acceptable for sending to the server
        let (usernameValid, usernameError) = isUserNameValid(username)
        if !usernameValid{
            return usernameError
        }
        
        //check whether the password is null
        guard let password = registerTextualInfo[UserRegistrationLocalizedString.InfoPasswordKey] as? String else{
            return UserRegistrationLocalizedString.NullPasswordError
        }
        
        //check whether the password is acceptable for sending to the server
        let (passwordValid, passwordError) = isPasswordValid(password)
        if !passwordValid{
            return passwordError
        }
        
        
        
        //check whether the fullname is valid
        guard let _ = registerTextualInfo[UserRegistrationLocalizedString.InfoFullnameKey] as? String else{
            return UserRegistrationLocalizedString.NullFullNameError
        }
       
        //check the email
        guard let email = registerTextualInfo[UserRegistrationLocalizedString.InfoEmailKey] as? String else{
            return UserRegistrationLocalizedString.NullEmailError
        }
        
        //check whether the email is acceptable for sending to the server
        let (emailValid, emailError) = isEmailValid(email)
        if !emailValid{
            return emailError
        }

        
        
        guard let mediaInfo = registerMediaInfo else{
            return UserRegistrationLocalizedString.NullAvatorError
        }
        
        HttpRequest.uploadImagesWithUserInfo(User.RegisterUserPath, images: mediaInfo, param: registerTextualInfo, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil && response != nil{
                    if response!["statusCode"] as! Int == 200{
                        completionHandler(registeredSucceed: true, registeredUserInfo: response!["info"] as? [String: AnyObject])
                    }else{
                        completionHandler(registeredSucceed: false, registeredUserInfo: nil)
                    }
                }else{
                    print(error)
                }
            })
        })
        return nil
    }
    
    
    
    /* MARK: Edit Profile func
        edit user profile
     */
    internal func doneEditingProfile(profileInfo: [String: AnyObject]?, completionHandler: (response: [String : AnyObject]?, error: String?) -> Void  ){
        if let profileInfo = profileInfo{
            let images = profileInfo[User.EditProfileMediaKey] as? [String: UIImage]
            
            var textualInfo = [String: AnyObject]()
            textualInfo[HttpRequest.SupportedParamKey.userId] = self.id
            if let additionalTextualInfo = profileInfo[User.EditProfileUserTextualInfoKey] as? [String: AnyObject]{
                textualInfo.addDictionaryToCurrent(additionalTextualInfo)
            }
            HttpRequest.uploadImagesWithUserInfo(User.EditProfilePath ,images: images, param: textualInfo, completionHandler: {
                (response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error != nil || response == nil{
                        completionHandler(response: nil, error: error)
                    }else{
                        if response!["statusCode"] as! Int == 200{
                            if let userInfo = response!["userInfo"] as? [String: AnyObject]{
                                completionHandler(response: userInfo , error: nil)
                            }
                        }else{
                             completionHandler(response: nil, error: nil)
                        }
                    }
                })
            })
        }
    }
    
    //  MARK: Add feature func
    //add feature
    internal func doneAddingFeature(featureInfo: [String: AnyObject]?, completionHandler: (response: Feature?, error: AddFeatureError) -> Void ){
        if let featureInfo = featureInfo{
            let images = featureInfo[User.AddFeatureMediaKey] as? [String: UIImage]
            
            var textualInfo = [String: AnyObject]()
            textualInfo[HttpRequest.SupportedParamKey.userId] = self.id
            if let additionalTextualInfo = featureInfo[User.AddFeatureTextualInfoKey] as? [String: AnyObject]{
                textualInfo.addDictionaryToCurrent(additionalTextualInfo)
            }
            print("good")
            HttpRequest.uploadImagesWithUserInfo(User.AddFeaturePath ,images: images, param: textualInfo, completionHandler: {
                (response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    print(response)
                    if error == nil && response != nil{
                        if let errorCode = response!["errorCode"] as? Int {
                            if errorCode == 0{
                                print("food")
                                if let featureInfo = response!["feature"] as? [String: AnyObject]{
                                    var featureInfo = featureInfo
                                    featureInfo["user"] = self
                                    let addedFeature = Feature(featureInfo: featureInfo)
                                    if self.features != nil{
                                        self.features!.insert(addedFeature, atIndex: 0)
                                    }else{
                                        self.features = [addedFeature]
                                    }
                                    completionHandler(response: addedFeature, error: .None)
                                }
                            }else{
                                let featureName = textualInfo["featureName"] as! String
                                if errorCode == 1{
                                    completionHandler(response: nil, error: AddFeatureError.MissingCover(alertTitle: "Missing cover photo for feature " + featureName, alertBody: "Please add a cover photo"))
                                }else if errorCode == 2{
                                     completionHandler(response: nil, error: AddFeatureError.ExistedFeature(alertTitle: featureName + " has been featuring already", alertBody: "What else do you want the nearby to know"))
                                }else{
                                     completionHandler(response: nil, error: AddFeatureError.UnKnown(alertTitle: "Failed to add feature", alertBody: "Please check your internet connection or Wifi settings"))
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
    
    
    internal func deleteFeature(feature: Feature, completionHandler: (Bool) -> Void){
        let featureId = feature.id
        let param: [String: AnyObject] = [
            "featureId": featureId,
            "userId": self.id!
        ]
        HttpRequest.sendRequest(User.DeleteFeaturePath, method: .POST, param: param, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil && response != nil{
                    if let status = response!["status"] as? Bool{
                        completionHandler(status)
                    }
                }else{
                    print(error)
                    completionHandler(false)
                }
            })
        })
    }
    
    
    
    internal func deletePostInFeature(post: Post, feature: Feature, completionHandler: (Bool) -> Void){
        feature.deletePost(post, userId: self.id!, completionHandler: completionHandler)
    }

  
    
    
    //check whether the given email has been registered already
    internal static func checkUserForEmailExists(email: String, completionHandler: Bool -> Void){
        let param = [ "email": email]
        
        HttpRequest.sendRequest(User.UserForEmailExistsPath, method: .GET, param: param, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil && response != nil{
                    if response!["exists"] as! String == "true"{
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                    
                }else{
                    print(error)
                }
            })
        })
    }
    
    //check whether the given username has been registered already
    internal static func checkUserForUsernameExists(username: String, completionHandler: Bool -> Void){
        let param = [ "username": username]
        
        HttpRequest.sendRequest(User.UserForUserNameExistsPath, method: .GET, param: param, completionHandler: {
            (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error == nil && response != nil{
                    if response!["exists"] as! String == "true"{
                        completionHandler(true)
                    }else{
                        completionHandler(false)
                    }
                    
                }else{
                    print(error)
                }
            })
        })
    }
    
    // save the credential to keychain so that the user won't need to login again
    internal static func saveUserCredentialToKeyChain(userId: Int, password: String){
        let userDefault = NSUserDefaults.standardUserDefaults()
        let keyChain = KeychainWrapper()
        keyChain.mySetObject(password, forKey: KeyChainLocalizedString.KeyChainObjectKeyForPassword)
        keyChain.mySetObject(userId, forKey:KeyChainLocalizedString.KeyChainObjectKeyForUserId)
        userDefault.setBool(true, forKey: KeyChainLocalizedString.KeyChainSetForUserDefaultKey)
    }
    
    //get user features as string
    internal func getUserFeaturesAsString() -> String?{
        var featureString = ""
        if let features = self.features{
            for feature in features{
                featureString += feature.featureName + ", "
            }
            featureString = featureString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ", "))
        }
        return featureString.isEmpty ? nil: featureString
    
    }
    
    
    internal func doesUserLikeThisPost(postId: Int) -> (liked: Bool, postLike: PostLike?){
        if postLikes == nil{
            return (false, nil)
        }
        for postLike in self.postLikes!{
            if postLike.postId == postId{
                return (true, postLike)
            }
        }
        return (false, nil)
    }
    

    
    //like a post, if the user has already liked the post, postLike should not be nil
    internal func toggleLikePost(post: Post, postLike: PostLike?, completionHandler: (PostLike?) -> Void){
        let param: [String: AnyObject] = [
            "userId": self.id!,
            "postId": post.id
        ]
        
        HttpRequest.sendRequest(User.ToggleLikePostPath, method: .GET, param: param, completionHandler: {
            (response, error) in
            if let likeDeletedId = response as? Int{
                if likeDeletedId > 0{
                    if let indexInUserOwnLikes = self.postLikes?.indexOf(postLike!){
                        self.postLikes?.removeAtIndex(indexInUserOwnLikes)
                       /* if let indexInPostLikes = post.postLikes?.indexOf(postLike!){
                            post.postLikes?.removeAtIndex(indexInPostLikes)
                        }*/
                        post.postLikeCount -= 1
                        completionHandler(nil)
                    }
                }
            }else if let likeAddedInfo = response as? [String: AnyObject]{
                let postLikeId = likeAddedInfo["post_like_id"] as! Int
                let postLikeTime = likeAddedInfo["like_time"] as! String
                let likeUserId = likeAddedInfo["liked_user_id"] as! Int
                let postLike = PostLike(postLikeId: postLikeId , likeTime: postLikeTime, likeUserId: likeUserId, post: post)
                postLike.postId = post.id
                
                if self.postLikes != nil{
                    self.postLikes!.insert(postLike, atIndex: 0)

                }else{
                    self.postLikes = [postLike]
                }
                
                if post.postLikes != nil{
                    post.postLikes!.insert(postLike, atIndex: 0)
                }else{
                    post.postLikes = [postLike]
                }
                post.postLikeCount += 1
                completionHandler(postLike)
            }
        })
    }
    
    internal func commentPost(text: String, post: Post, completionHandler: (PostComment?) -> Void){
        guard !text.isEmpty else{
            return
        }
        
        let postId = post.id
        guard let commentUserId = self.id else{
            return
        }
        let param: [String: AnyObject] = [
            "commentInfo": ["postId": postId, "comment_user_id": commentUserId, "text": text]
        ]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
           let loadingGroup = dispatch_group_create()
            dispatch_group_enter(loadingGroup)
            var addedComment: PostComment?
            HttpRequest.sendRequest(User.CommentPostPath, method: .GET, param: param, completionHandler: {
                (response, error) in
                    if error == nil && response != nil{
                        if var commentInfo = response as? [String: AnyObject]{
                            commentInfo["post"] = post
                            let postComment = PostComment(commentInfo: commentInfo)
                            if postComment.mentionedUserIdList != nil{
                                postComment.mentionedUserList = [User]()
                                for mentionedUserId in postComment.mentionedUserIdList!{
                                    dispatch_group_enter(loadingGroup)
                                    postComment.mentionedUserList!.append(User(id: mentionedUserId, completionHandler: {
                                        (succeed, info) in
                                        dispatch_group_leave(loadingGroup)
                                    })!)
                                }
                            }
                            addedComment = postComment
                            if post.postComments != nil{
                                post.postComments?.insert(addedComment!, atIndex: 0)
                            }else{
                                post.postComments = [addedComment!]
                            }
                        }
                    }
                    dispatch_group_leave(loadingGroup)
            })
            dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(addedComment)
            })
        })
    }
 
    
//    
//    internal func commentPost(text: String, post: Post, completionHandler: (PostComment?) -> Void){
//        guard !text.isEmpty else{
//            return
//        }
//        
//        let postId = post.id
//        guard let commentUserId = self.id else{
//            return
//        }
//        let param: [String: AnyObject] = [
//            "commentInfo": ["postId": postId, "comment_user_id": commentUserId, "text": text]
//        ]
//        
//        HttpRequest.sendRequest(User.CommentPostPath, method: .GET, param: param, completionHandler: {
//            (response, error) in
//            if error == nil && response != nil{
//                if var commentInfo = response as? [String: AnyObject]{
//                    commentInfo["post"] = post
//                    let postComment = PostComment(commentInfo: commentInfo)
//                    if post.postComments != nil{
//                        post.postComments?.insert(postComment, atIndex: 0)
//                    }else{
//                        post.postComments = [postComment]
//                    }
//                    completionHandler(postComment)
//                }
//            }
//        })
//    }

    

    //check whether the credential is in the keychain or not and verify it
    internal static func isUserCredentialKeyChainPresented(completionHander: (valid: Bool, userId: Int?) -> Void){
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.objectForKey(KeyChainLocalizedString.KeyChainSetForUserDefaultKey) != nil{
            //if keychain is presented, verify automatcally
            if userDefault.boolForKey(KeyChainLocalizedString.KeyChainSetForUserDefaultKey){
                let keyChain = KeychainWrapper()
                let password = keyChain.myObjectForKey(KeyChainLocalizedString.KeyChainObjectKeyForPassword) as! String
                let userId = keyChain.myObjectForKey(KeyChainLocalizedString.KeyChainObjectKeyForUserId) as! Int
                User.authenticateUserByUserIdAndPassword(userId, password: password, completionHandler: {
                    valid in
                    dispatch_async(dispatch_get_main_queue(), {
                        if valid{
                            completionHander(valid: true, userId: userId)
                        }else{
                            completionHander(valid: false, userId: nil)
                        }
                    })
                })
            }else{
                completionHander(valid: false, userId: nil)
            }
        }else{
            completionHander(valid: false, userId: nil)
        }
    }
    
    
    
    //authenticate a user based on the given username or email and password
    internal static func authenticateUserByIdenAndPassword(iden: String, password: String, completionHandler: ( valid: Bool, userId: Int?, error: authenticationError? ) -> Void){
        
        var requestUrl: String?
        var paramKey: String?
        //if the recieve iden is a email format 
        let (emailValid, _) = isEmailValid(iden)
        
        if emailValid{
            paramKey = "email"
            requestUrl = UserAuthenticationByEmailPasswordPath
        }else{
            let (usernameValid, _) = isUserNameValid(iden)
            if usernameValid{
                paramKey = "username"
                requestUrl = UserAuthenticationByUsernamePasswordPath
            }
        }
        
        if requestUrl != nil{
            let param = [
                paramKey!: iden,
                "password": password
            ]
            HttpRequest.sendRequest(requestUrl!, method: .POST, param: param, completionHandler: {
                (response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil && response != nil{
                        if response!["valid"] as! Bool{
                            completionHandler(valid: true, userId: response!["userId"] as? Int, error: nil)
                        }else{
                            completionHandler(valid: false, userId: nil, error: authenticationError.IncorrectPassword(title: "Invalid password for " + iden, body: "The password you entered is incorrect, please try again"))
                        }
                    }else{
                        completionHandler(valid: false, userId: nil, error: authenticationError.NoInternetConnection(title: "No internet connection", body: "The internet is unavailable, please check your internet connection"))
                    }
                })
            })
        }else{
            completionHandler(valid: false, userId: nil, error: authenticationError.Unknown(title: "Login failed", body: "Please make sure the information you entered is correct"))
            
        }
    }
    
    
    //authenticate the user by user id and password, usually called from isUserCredentialKeyChainPresented
    internal static func authenticateUserByUserIdAndPassword(userId: Int, password: String, completionHandler: ( Bool ) -> Void){
            let param: [String: AnyObject] = [
                "userId": userId,
                "password": password
            ]
            HttpRequest.sendRequest(UserAuthenticationByUserIdPasswordPath, method: .POST, param: param, completionHandler: {
                (response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if error == nil && response != nil{
                        if response!["valid"] as! Bool{
                            completionHandler(true)
                        }else{
                            completionHandler(false)
                        }
                    }else{
                        completionHandler(false)
                    }
            })
        })
    }
    
    
    
    
    
    
    
    
    //fetch user information, such bio, fullname etc.
    private func fetchUserInfoById(fetchPath: String, id: Int, callBack: ([String: AnyObject] -> Void)?  ) -> Void{
        let fetchingIdenInfo = [UserInfoLocalizedString.fetchingCredentialUserIdNameKey: String(id)]
        let httpRequest = HttpRequest(requestPath: fetchPath, parameterInfo: fetchingIdenInfo)
        
        httpRequest.send(completionHandler: {
            respondData in
            if callBack != nil{
                dispatch_async(dispatch_get_main_queue(), {
                    callBack!(respondData)
                })
            }
        })
    }
}

extension User: Equatable{
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username || lhs.id == rhs.id
}


func !=(lhs: User, rhs: User) -> Bool {
    return !(lhs == rhs)
}


