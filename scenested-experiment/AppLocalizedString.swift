//
//  AppLocalizedString.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/29/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation


struct UserRegistrationLocalizedString{
        //info key of registeration dictionary
        static let InfoUsernameKey: String = "username"
        static let InfoFullnameKey: String = "fullname"
        static let InfoEmailKey: String = "email"
        static let InfoPasswordKey: String = "password"
        static let InfoUserDeviceTokenKey: String = "deviceToken"
        static let InfoAvatorKey: String = "avator"
    
    
        //possible error for registeration
        static let IllegibleEmailError = "The email address seems invalid"
        static let UserNameNoLetterError = "A username needs to contain letters"
        static let IllegibleUserNameError = "A valid username has minimum length of 4 characters, and may only contains letters, numbers and underscore" //error for illigal characters and length of the registeration username
        static let IllegibleFullnameError = ""
        static let NullUsernameError = "Username can not be empty"
        static let IllegiblePasswordError = "A valid password has minimum length of 6 characters, and a strong password should be a combination of letters, numbers, and symbols"
        static let NullPasswordError = "Password can not be null"
        static let NullDeviceToken = "Device token is empty"
        static let NullAvatorError = "Please add a photo for your avator"
        static let NullFullNameError = "Please enter your fullname"
        static let NullEmailError = "Please enter your email address"
}


struct RangingFeatureLocalizedString{
    static let RequestUserIdKey = "request_user_id"
    static let ComeAcrossUserIdKey = "come_across_user_id"
}

struct NotificationLocalizedString{
    static let PushProfileViewControllerNotificationName = "PushProfileViewControllerNotification"
    static let PushTabBarVCNotificationName = "PushTabBarVCNotification"
    static let AddFeatureSucceedNotification = "AddFeatureSucceedNotification"
    static let PostLikeCountLabelTappedNotification = "PostLikeCountLabelTappedNotification"
    static let PostDotIconTappedNotification = "PostDotIconTappedNotification"
    static let FinishedFetchingUserInfoNotificationName = "FinishedFetchingUserInfoNotificationName"
    static let profileNavigatableViewTappedNotificationName = "profileNavigatableViewTappedNotification"
    
    static let ProfileUpdatedSucceedNotificationName = "profileUpdatedSucceedNotification"
    static let FinishedCommentNotificationName = "FinishedCommentNotification"
    static let TextViewTappedNotificationName = "TextViewTappedNotification"
    static let TextViewMentionedTappedNotificationName = "TextViewMentionedTappedNotification"
    static let PostsOfFeatureUpdatedNotificationName = "PostsOfFeatureUpdatedNotification"
    
    
    static let RespondUserIdNameKey = "userId"
    static let RespondUserNameKey = "username"
    
}

struct UserInfoLocalizedString{
    static let fetchingCredentialUserIdNameKey = "userId"
}

struct KeyChainLocalizedString{
    static let KeyChainSetForUserDefaultKey = "keyChainSet"
    static let KeyChainObjectKeyForPassword = kSecValueData
    static let KeyChainObjectKeyForUserId = kSecAttrAccount
}

struct AlertErrorLocalizedString{
    static let errorTitleKey = "errorTitle"
    static let errorBodyKey = "errorBody"
}



struct CachePrefix{
    static let CachePrefixForFeatureCover = "FeatureCover-"
    static let CachePrefixForPostPhoto = "PostPhoto-"
    static let CachePrefixForProfileAvator = "ProfileAvator-"
    static let CachePrefixForProfileCover = "ProfileCover-"
    
}