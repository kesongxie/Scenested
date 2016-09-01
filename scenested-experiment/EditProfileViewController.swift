//
//  EditProfileViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/17/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class EditProfileViewController: EditableProfileViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileAvator: UIImageView!{
        didSet{
            profileAvator.layer.cornerRadius = 45
            profileAvator.clipsToBounds = true
            profileAvator.layer.borderColor = UIColor.whiteColor().CGColor
            profileAvator.layer.borderWidth = 3.0
            
        }

    }
    
    @IBOutlet weak var profileCover: UIImageView!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!

    private var isKeyBoardActive: Bool = false //true when the keyboard is currently visible
    
    private var isUIAdjustingWhileKeyBoardShows: Bool = false //when the keyboard shows, the offset of the view will be adjusted based upon the frame of the keyboard, set to yes, if the View is on the process of adjusting the UI
    
    private var firstResponderObject: AnyObject?
    
    @IBOutlet weak var coverCameraIcon: UIImageView!
    @IBOutlet weak var avatorCameraIcon: UIImageView!
    
    var profileAvatorImage: UIImage?{
        didSet{
            profileAvator?.image = profileAvatorImage
            avatorCameraIcon?.hidden = true
        }
    }
    
    var profileCoverImage: UIImage?{
        didSet{
            profileCover?.image = profileCoverImage
            coverCameraIcon?.hidden = true
        }
    }
    
    var fullNameText: String?{
        didSet{
            fullNameTextField?.text = fullNameText
        }
    }
    
    var bioText: String?{
        didSet{
            bioTextView?.text = bioText
        }
    }
    
    var isProfileCoverEditted: Bool = false
    var isPorfileAvatorEditted: Bool = false
    
    
    
    
    @IBOutlet weak var leftTopNaviItemBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var rightTopNaviItemBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    
    @IBOutlet weak var profileVisibleSwitcher: UISwitch!{
        didSet{
            if let user = (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser{
                profileVisibleSwitcher.on = user.profileVisible
            }
        }
    }
    
    
    @IBAction func FinishEditingProfile(sender: UIBarButtonItem) {
        view.endEditing(true)
        
        let fullName =  fullNameTextField.text ?? ""
        guard !fullName.isEmpty else{
            let alert = UIAlertController(title: "Full name is Empty", message: "Please enter your full name", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: {
                alertAction in
                self.fullNameTextField.becomeFirstResponder()
            })
            alert.addAction(okayAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        
        self.navigationBar?.title = "Saving Profile..."
        self.rightTopNaviItemBtn.enabled = false
        let profileVisibleSetting = (profileVisibleSwitcher.on) ? 1 : 0

        
        
        let textualInfo: [String: AnyObject] = [
            HttpRequest.SupportedParamKey.fullname: fullNameTextField.text!,
            HttpRequest.SupportedParamKey.bio: bioTextView.text,
            HttpRequest.SupportedParamKey.profileVisible: profileVisibleSetting
        ]
        
        
        var images = [String: UIImage]()
        if  isProfileCoverEditted{
            if let coverImage = profileCover.image{
                images[HttpRequest.SupportedParamKey.cover] = coverImage
            }
        }
        
        if isPorfileAvatorEditted{
            if let avatorImage = profileAvator.image{
                 images[HttpRequest.SupportedParamKey.avator] = avatorImage
            }
        }
        
        let profileInfo: [String: AnyObject] = [
            User.EditProfileUserTextualInfoKey: textualInfo,
            User.EditProfileMediaKey: images
        ]
        
        getLoggedInUser()?.doneEditingProfile(profileInfo, completionHandler: {
            (responseInfo, error) in
            if error != nil{
                print(error)
            }else{
              if responseInfo != nil{
                getLoggedInUser()!.updateLoggedInUserWithInfoAfterUpdatingProfile(responseInfo!)
                    let profileUpdatedSucceedNotification = NSNotification(name: NotificationLocalizedString.ProfileUpdatedSucceedNotificationName, object: self, userInfo: nil)
                    NSNotificationCenter.defaultCenter().postNotification(profileUpdatedSucceedNotification)
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
              }
            }
        })
    }
    
    override func viewDidLoad() {
        if let fullname = fullNameText{
            fullNameTextField.text =  fullname
        }
        if let bio = bioText{
            bioTextView.text = bio
            placeHolderLabel.hidden = !bio.isEmpty
        }
        
        fullNameTextField.delegate = self
        bioTextView.delegate = self
        
        
        self.navigationItem.rightBarButtonItem?.becomeStyleBarButtonItem()
        
        self.dismissKeyBoardWhenTapped()
        self.navigationController?.navigationBar.backgroundColor = StyleSchemeConstant.navigationBarStyle.backgroundColor
        self.navigationController?.navigationBar.translucent = StyleSchemeConstant.navigationBarStyle.translucent
        updateAvator()
        updateCover()
        addTapGestureForAvator()
        addTapGestureForCover()
       
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        //strechy header set up
        self.globalScrollView = scrollView
        self.coverImageView = profileCover
        self.coverHeight = profileCover.bounds.size.height
        self.stretchWhenContentOffsetLessThanZero = true
        
        //keyboard set up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyBoardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func updateAvator(){
        if let avator = profileAvatorImage{
            avatorCameraIcon?.hidden = true
            profileAvator?.image = avator
        }
    }
    
    func updateCover(){
        if let cover = profileCoverImage{
            coverCameraIcon?.hidden = true
            profileCover?.image = cover
            if let coverImageSize = profileCover.image?.size{
                coverHeightConstraint.constant =  UIScreen.mainScreen().bounds.size.width * coverImageSize.height / coverImageSize.width
            }
        }
    }
    
    func addTapGestureForAvator(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tapAvator))
        profileAvator.addGestureRecognizer(tap)
    }
    
    func addTapGestureForCover(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.tapCover))
        profileCover.addGestureRecognizer(tap)
    }
    
    
   
    func keyboardDidShow(notification: NSNotification){
       if let keyboardFrame = notification.keyboardEndFrame{
            isUIAdjustingWhileKeyBoardShows = true
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
            if let firstResponser = firstResponderObject{
                let targetOriginFrameBottom = firstResponser.frame.origin.y + firstResponser.frame.size.height
                let viewShouldScroll = targetOriginFrameBottom - (view.bounds.size.height - keyboardFrame.size.height) + 10
                UIView.animateWithDuration(0.3, animations: {
                    self.scrollView.contentOffset.y = viewShouldScroll
                    }, completion: { finished in
                        self.isUIAdjustingWhileKeyBoardShows = false
                        self.isKeyBoardActive = true
                })
            }
        
        }
    }
    
    

    
    func keyBoardWillHide(notification: NSNotification){
         scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
         isKeyBoardActive = false
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if isKeyBoardActive && !isUIAdjustingWhileKeyBoardShows{
            view.endEditing(true)
        }
    }
}

extension EditProfileViewController: UITextViewDelegate{
    func textViewDidBeginEditing(textView: UITextView) {
        firstResponderObject = textView
    }
    
    func textViewDidChange(textView: UITextView) {
        placeHolderLabel.hidden = !textView.text.isEmpty
    }
    
}

extension EditProfileViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        firstResponderObject = textField
    }
}

