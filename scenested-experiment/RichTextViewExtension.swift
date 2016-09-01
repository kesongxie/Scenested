//
//  RichTextView.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/22/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

let HashTagAttributeName = "hashtag"
let MentionedAttributeName = "mentioned"
let LoadMentionedUserPath = HttpCallPath + "LoadMentionedUser.php"


extension UITextView {
    
    
    
    func preLoadTextViewTextWithMentionedUser(text: String, completionHandler: ([User]?) -> Void){
        if text.characterCount == 0{
            self.setBioDefaultText()
            return
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.6
        
        let font = UIFont.systemFontOfSize(15)
        
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font
        ]
        let mutableAttributedString = NSMutableAttributedString(string: text)
        mutableAttributedString.addAttributes(attributes, range: text.fullRange())
        self.attributedText = mutableAttributedString
        
        let param: [String: AnyObject] = [
            "text": text
        ]
        
        HttpRequest.sendRequest(LoadMentionedUserPath, method: .GET, param: param, completionHandler: {
            (response, error) in
            if error == nil && response != nil{
                var mentionedUsers = [User]()
                if let userInfoList = response as? [[String: AnyObject]]{
                    for userInfo in userInfoList{
                        mentionedUsers.append(User(userInfo: userInfo))
                    }
                }
                completionHandler(mentionedUsers)
            }
        })
        
    }
    
    
    
    func setStyleBackText(text: String){
        if text.characterCount == 0{
            self.setBioDefaultText()
            return 
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.6
        
        let font = UIFont.systemFontOfSize(15)
        
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font
        ]
        
        
        let mutableAttributedString = NSMutableAttributedString(string: text)
        mutableAttributedString.addAttributes(attributes, range: text.fullRange())
        self.attributedText = mutableAttributedString

        //add hash tag and metion attributes(color, tap gesture)
        let words = self.text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let hashTagOrMentionedRegx = try! NSRegularExpression(pattern: "[#|@][\\w]+", options: .CaseInsensitive)
        for word in words.filter({ hashTagOrMentionedRegx.numberOfMatchesInString($0, options: [], range: $0.fullRange()) > 0 }){
            let matches = hashTagOrMentionedRegx.matchesInString(word, options: [], range: word.fullRange())
            
            for match in matches{
                let stringToBeHighlighted = (word as NSString).substringWithRange(match.rangeAtIndex(0))
               let keyword = (stringToBeHighlighted as NSString).substringFromIndex(1)
                //get the range of the highlighted string
                let range = (self.text as NSString).rangeOfString(stringToBeHighlighted) //return NSString when the receiver is a NSString, otherwise if it's Stirng, this return Range<index>
                
                mutableAttributedString.addAttributes([NSForegroundColorAttributeName: StyleSchemeConstant.linkColor], range: range)
                
                if stringToBeHighlighted.containsString("#"){
                    mutableAttributedString.addAttribute(HashTagAttributeName, value: keyword, range: range)
                }else if stringToBeHighlighted.containsString("@"){
                    mutableAttributedString.addAttribute(MentionedAttributeName, value: keyword, range: range)
                }
            }
            
        }
        self.attributedText = mutableAttributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UITextView.textViewTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setStyleText(text: String){
        if text.characterCount == 0{
            self.setBioDefaultText()
            return
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.6
        
        let font = UIFont.systemFontOfSize(15)
        
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font
        ]
        
        
        let mutableAttributedString = NSMutableAttributedString(string: text)
        mutableAttributedString.addAttributes(attributes, range: text.fullRange())
        self.attributedText = mutableAttributedString

        
        let hashTagOrMentionedRegx = try! NSRegularExpression(pattern: "[#|@][\\w]+", options: .CaseInsensitive)
        hashTagOrMentionedRegx.enumerateMatchesInString(text, options: .WithTransparentBounds, range: text.fullRange(), usingBlock: {
            (checkingResult, flag, stop) in
            if let range = checkingResult?.range{
                mutableAttributedString.addAttributes([NSForegroundColorAttributeName: StyleSchemeConstant.linkColor], range: range)
                let stringToBeHighlighted = (text as NSString).substringWithRange(range)
                let keyword = (stringToBeHighlighted as NSString).substringFromIndex(1)
                if stringToBeHighlighted.containsString("#"){
                    mutableAttributedString.addAttribute(HashTagAttributeName, value: keyword, range: range)
                }else if stringToBeHighlighted.containsString("@"){
                    mutableAttributedString.addAttribute(MentionedAttributeName, value: keyword, range: range)
                }
            }
        })
        self.attributedText = mutableAttributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UITextView.textViewTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func textViewTapped(tapGesture: UITapGestureRecognizer){
        let point = tapGesture.locationInView(self)
        self.selectable = true
        if let position = closestPositionToPoint(point){
            let range = tokenizer.rangeEnclosingPosition(position, withGranularity: .Word, inDirection: 1)
            if range != nil {
                let location = offsetFromPosition(beginningOfDocument, toPosition: range!.start)
                let length = offsetFromPosition(range!.start, toPosition: range!.end)
                let attrRange = NSMakeRange(location, length)
                let word = attributedText.attributedSubstringFromRange(attrRange)
                if let hashTagValue = word.attribute(HashTagAttributeName, atIndex: 0, effectiveRange: nil ) {
                    print(hashTagValue)
                }else if let mentionedValue = word.attribute(MentionedAttributeName, atIndex: 0, effectiveRange: nil ){
                   
                    let userInfo: [String: AnyObject] = [
                        "mentionedUserName": mentionedValue,
                        "textView": self
                    ]
                    let textViewMentionedTappedNotification = NSNotification(name: NotificationLocalizedString.TextViewMentionedTappedNotificationName, object: self, userInfo: userInfo)
                        NSNotificationCenter.defaultCenter().postNotification(textViewMentionedTappedNotification)
                    print(mentionedValue)
                }else{
                    let userInfo: [String: AnyObject] = [
                        "textView": self
                    ]
                    let textViewTappedNotification = NSNotification(name: NotificationLocalizedString.TextViewTappedNotificationName, object: self, userInfo: userInfo)
                    NSNotificationCenter.defaultCenter().postNotification(textViewTappedNotification)
                }
                
                
            }
        }
        self.selectable = false
    }
    
    
    func setBioDefaultText(){
        self.text = "No introduction yet."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.6
        
        let font = UIFont.systemFontOfSize(15)
        
        let attributes: [String: AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor(red: 120 / 255.0, green: 120 / 255.0, blue: 120 / 255.0, alpha: 1)
        ]
        
        let mutableAttributedString = NSMutableAttributedString(string: text)
        mutableAttributedString.addAttributes(attributes, range: text.fullRange())
        self.attributedText = mutableAttributedString

    }
    
    
    
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
