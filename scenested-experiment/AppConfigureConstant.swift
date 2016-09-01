//
//  AppConfigureConstant.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/25/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import UIKit

let APPUUID: String = "671002C3-B3A5-4639-9C42-69E868FE81B7"
let BeaconIdentifier: String = NSBundle.mainBundle().bundleIdentifier!
let APPCLBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: APPUUID)!, identifier: BeaconIdentifier)
let AppCBUUID = CBUUID(NSUUID:  NSUUID(UUIDString: APPUUID)! )
let UsernameMinLength:Int = 4
let PasswordMinLength:Int = 6
let ProfileCoverAspectRatio: CGFloat = 3.2

let ServerRoot = "http://192.168.1.104:8888/iOS/"
let HttpCallPath = ServerRoot + "User/HttpCall/"
let RangingSimilarFeaturePath = ServerRoot + "PushNotification/RangeSimilarfeature.php"
let FetchUserInfoPath = HttpCallPath + "FetchingUserInfo.php"


struct StoryboardIden{
    static let GuestProfileNavigationControllerIden = "GuestProfileNavigationControllerIden"
    static let GuestProfileViewControllerIden = "GuestProfileViewControllerIden"
    static let GlobalTabBarControllerIden = "GlobalTabBarControllerIden"
    static let LoginNavigationViewControllerIden = "LoginNavigationViewControllerIden"
    static let SignUpViewControllerIden = "SignUpViewControllerIden"
    static let EditProfileNaviIden = "EditProfileNaviIden"
    static let SignUpUserNamePasswordViewControllerIden = "SignUpUserNamePasswordViewControllerIden"
    static let WelcomeViewControllerIden = "WelcomeViewControllerIden"
    static let ProfileNavigationControllerIden = "ProfileNavigationControllerIden"
    static let AddFeatureNavigationControllerIden = "AddFeatureNavigationControllerIden"
    static let EditPostNavigationViewControllerIden = "EditPostNavigationViewControllerIden"
    static let PostOnTableViewControllerIden = "PostOnTableViewControllerIden"
    static let FeatureViewControllerIden = "FeatureViewControllerIden"
    static let PostLikeTableViewControllerIden = "PostLikeTableViewControllerIden"
    static let ProfileViewControllerIden = "ProfileViewControllerIden"
    static let PostOnNavigationViewControllerIden = "PostOnNavigationViewControllerIden"
    static let ComposeCommentNavigationViewControllerIden = "ComposeCommentNavigationViewControllerIden"
    static let ComposeCommentViewControllerIden = "ComposeCommentViewControllerIden"
    static let PostCommentViewControllerIden = "PostCommentViewControllerIden"
    static let UserNotExistViewControllerIden = "UserNotExistViewControllerIden"
    static let PostCommentNavigationControllerIden = "PostCommentNavigationControllerIden"
}

