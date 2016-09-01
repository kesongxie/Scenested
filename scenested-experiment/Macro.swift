//
//  UtilityFunctions.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/6/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit


enum ProceedBtnStatus{
    case BtnShouldLoadWithInterationDisabled
    case BtnStopLoadingWithInterationEnabled
}

enum UploadPhotoFor{
    case profileAvator
    case profileCover
    case featureCover
    case profilePost
    case signUpAvator
    case postPicture
    case none
}


enum AddFeatureError {
    case MissingCover(alertTitle: String, alertBody: String )
    case ExistedFeature(alertTitle: String, alertBody: String )
    case UnKnown(alertTitle: String, alertBody: String)
    case None
}

enum AddPostError{
    case MissingPhoto(alertTitle: String, alertBody: String )
    case UnKnown(alertTitle: String, alertBody: String)
    case None

}


enum CacheType{
    case CacheForFeatureCover
    case CacheForPostPhoto
    case CacheForProfileAvator
    case CacheForProfileCover
}

enum DefaultViewOpenOption{
    case Loading
    case NoContentMessage
}



func getAspectRatioFromSize(size: CGSize) -> CGFloat{
    return size.width / size.height
}

func isEmailValid(email: String) -> (valid: Bool, error: String?){
    let emailValidExpression = try! NSRegularExpression(pattern: "^[a-zA-Z]+[\\w.]+@[\\w.]+[.][\\w]+$", options: .CaseInsensitive)
    
    if emailValidExpression.firstMatchInString(email, options: .WithoutAnchoringBounds, range: email.fullRange()) == nil{
        return (false, UserRegistrationLocalizedString.IllegibleEmailError)
    }else{
        return (true, nil)
    }
}

func isFullNameValid(fullname: String) -> (valid: Bool, error: String?){
    let fullNameAfterTrimmed = fullname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let fullnameValidExpression = try! NSRegularExpression(pattern: "^[\\w ]+$", options: .CaseInsensitive)
    if fullnameValidExpression.firstMatchInString(fullNameAfterTrimmed, options: .WithoutAnchoringBounds, range: fullNameAfterTrimmed.fullRange()) == nil{
        return (false, UserRegistrationLocalizedString.IllegibleFullnameError)
    }else{
        return (true, nil)
    }
}


func isPasswordValid(password: String) -> (valid: Bool, error: String?){
    if password.characterCount < PasswordMinLength{
        return (false, UserRegistrationLocalizedString.IllegiblePasswordError)
    }else{
        return (true, nil)
    }
}

func isUserNameValid(username: String) -> (valid: Bool, error: String?){
    let containsLetter = try! NSRegularExpression(pattern: "[a-zA-Z]+", options: .CaseInsensitive)
    guard containsLetter.firstMatchInString(username, options: .WithoutAnchoringBounds, range: username.fullRange()) != nil else{
        return (false, UserRegistrationLocalizedString.UserNameNoLetterError)
    }
    
    let usernameInValidExpression = try! NSRegularExpression(pattern: "[^\\w]+", options: .CaseInsensitive)
    
    if usernameInValidExpression.firstMatchInString(username, options: .WithoutAnchoringBounds, range: username.fullRange()) != nil || username.characterCount < UsernameMinLength{
        return (false, UserRegistrationLocalizedString.IllegibleUserNameError)
    }else{
         return (true, nil)
    }

}

/*
    status: the status for the button
    btnInitialTitle: the initial title for the button(before tapped)
    activityIndicator: the loading spinner asscicate with the button
 */

func adjustProceedBtnUI(status: ProceedBtnStatus, btn: UIButton, btnInitialTitle: String, activityIndicator: UIActivityIndicatorView){
    switch status{
    case .BtnShouldLoadWithInterationDisabled:
        btn.setTitle("", forState: .Normal)
        btn.userInteractionEnabled = false
        btn.alpha = 0.6
        activityIndicator.startAnimating()
    case .BtnStopLoadingWithInterationEnabled:
        activityIndicator.stopAnimating()
        btn.userInteractionEnabled = true
        btn.alpha = 1
        btn.setTitle(btnInitialTitle, forState: .Normal)
    }
}

func getLoggedInUser() -> User?{
    return (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser
}

func setLoggedInUser(userId: Int, completionHandler: (succeedLogin: Bool, respondInfo: AnyObject?) -> Void ){
    (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser =  User(id: userId, completionHandler: {
        (succeed, info) in
        completionHandler(succeedLogin: succeed, respondInfo: info)
    })
}

func getLoggedInUserFeatureCount() -> Int{
    return getLoggedInUser()?.features?.count ?? 0
}



//guarantee unique for each cache object
func getCacheKeyForType(uniqueIden: String, cacheType: CacheType) -> String?{
    var cachePrefix: String = ""
    switch cacheType{
    case .CacheForFeatureCover:
       cachePrefix = CachePrefix.CachePrefixForFeatureCover
    case .CacheForPostPhoto:
        cachePrefix = CachePrefix.CachePrefixForPostPhoto
    case .CacheForProfileAvator:
        cachePrefix = CachePrefix.CachePrefixForProfileAvator
    case .CacheForProfileCover:
        cachePrefix = CachePrefix.CachePrefixForProfileCover
    }
    return cachePrefix + uniqueIden
}

func getGlobalCache() -> NSCache?{
    return (UIApplication.sharedApplication().delegate as? AppDelegate)?.globalCache
}

func convertDateStringToElapseTime(dateString: String?) -> String?{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateString != nil ? dateFormatter.dateFromString(dateString!)?.elapsedTime : nil
}

func getBackBtnAsUIBarBtnItem() -> UIBarButtonItem{
    let backBtn = UIBarButtonItem()
    backBtn.tintColor = StyleSchemeConstant.themeMainTextColor
    backBtn.image = UIImage(named: "back-icon")
    return backBtn
}

//change the appearance of the like label and image to active style
func setActiveLikePostStatusUI(heartImageView: UIImageView, likeCountLabel: UILabel){
    heartImageView.image = StyleSchemeConstant.LikeLabel.LikeLabelHeartActiveImage
    likeCountLabel.textColor = StyleSchemeConstant.LikeLabel.ActiveTitleColor
    likeCountLabel.font = StyleSchemeConstant.LikeLabel.LabelTextActiveFont
}

func setDeActiveLikePostStatusUI(heartImageView: UIImageView, likeCountLabel: UILabel){
    heartImageView.image = StyleSchemeConstant.LikeLabel.LikeLabelHeartDeActiveImage
    likeCountLabel.textColor = StyleSchemeConstant.LikeLabel.DeActiveTitleColor
    likeCountLabel.font = StyleSchemeConstant.LikeLabel.LabelTextDeActiveFont
}

//retrive a list of tagged user's names from text, nil if failed
func retrieveTagUserNameListFromText(text: String) -> [String]?{
    var tagUserNameList = [String]()
    let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    let mentionedRegx = try! NSRegularExpression(pattern: "[@][\\w]+", options: .CaseInsensitive)
    for word in words.filter({ mentionedRegx.numberOfMatchesInString($0, options: [], range: $0.fullRange()) > 0 }){
        let matches = mentionedRegx.matchesInString(word, options: [], range: word.fullRange()) //for @username1@username2 case
        for match in matches{
            let mentioned = (word as NSString).substringWithRange(match.range) //match.range gets the range of the reciever represents, in this case the match
            let username = (mentioned as NSString).substringFromIndex(1) //remove the @
            //get the range of the highlighted string
            tagUserNameList.append(username)
        }
    }
    return tagUserNameList.count > 0 ? tagUserNameList: nil
}



/*
 
 
 
 //    let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
 
 
 //    for word in words.filter({ hashTagOrMentionedRegx.numberOfMatchesInString($0, options: [], range: $0.fullRange()) > 0 }){
 //        let matches = hashTagOrMentionedRegx.matchesInString(word, options: [], range: word.fullRange())
 //
 //        for match in matches{
 //            let stringToBeHighlighted = (word as NSString).substringWithRange(match.rangeAtIndex(0))
 //            let keyword = (stringToBeHighlighted as NSString).substringFromIndex(1)
 //            //get the range of the highlighted string
 //            let range = (self.text as NSString).rangeOfString(stringToBeHighlighted) //return NSString when the receiver is a NSString, otherwise if it's Stirng, this return Range<index>
 //
 //        }
 */

func setAttributedStyleText(text: String){
    let hashTagOrMentionedRegx = try! NSRegularExpression(pattern: "[#|@][\\w]+", options: .CaseInsensitive)
    hashTagOrMentionedRegx.enumerateMatchesInString(text, options: .WithTransparentBounds, range: text.fullRange(), usingBlock: {
        (checkingResult, flag, stop) in
        print(checkingResult?.range)
        
    
    })
    
    
    
    
    
    
    
  }




