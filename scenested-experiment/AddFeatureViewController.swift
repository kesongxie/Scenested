//
//  AddfeatureViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/21/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class AddFeatureViewController: StrechableHeaderViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var featureCoverImageView: UIImageView!
    
    @IBOutlet weak var featureNameTextField: UITextField!
    
    private var profileCoverHeight: CGFloat = 0
    
    private var isKeyBoardActive: Bool = false //true when the keyboard is currently visible
    
    private var isUIAdjustingWhileKeyBoardShows: Bool = false //when the keyboard shows, the offset of the view will be adjusted based upon the frame of the keyboard, set to yes, if the View is on the process of adjusting the UI

    
    private var bottomInsetWhenKeyboardShows:CGFloat = 160
    
    private var featureCoverAspectRatio:CGFloat = 1
    
    @IBOutlet weak var featureCoverHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    
    private var firstResponderObject: AnyObject?
    
    @IBAction func addFeatureBtnTapped(sender: UIBarButtonItem) {
        view.endEditing(true)
        guard let featureName = featureNameTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else{
            return
        }
        if featureName.isEmpty{
            let alert = UIAlertController(title: "Feature Name is Empty", message: "Please enter the name for your new feature", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: {
                alertAction in
                self.featureNameTextField.becomeFirstResponder()
            })
            alert.addAction(okayAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard let featureCover = featureCoverImageView?.image else{
            let alert = UIAlertController(title: "Feature Cover is Empty", message: "Please select a photo as your feature cover", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okayAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        self.navigationItem.title = "Adding Feature...."
        sender.enabled = false
        
        let textualInfo: [String: AnyObject] = [
            User.AddFeatureNameKey: featureName
        ]
        let images = [
           User.AddFeaturePhotoKey: featureCover
        ]
        
        
        let featureInfo: [String: AnyObject] = [
            User.AddFeatureMediaKey: images,
            User.AddFeatureTextualInfoKey: textualInfo
        ]
        
        getLoggedInUser()?.doneAddingFeature(featureInfo, completionHandler: {
            (response, addFeatureError) in
            var alertTitile: String?
            var alertBody: String?
            var needReEnterFeatureName = false
            switch addFeatureError{
            case .None:
                //suceed adding theme
                if let feature = response{
                    let addFeatureSucceedNotification = NSNotification(name: NotificationLocalizedString.AddFeatureSucceedNotification, object: self, userInfo: [
                        "feature": feature
                        ])
                    NSNotificationCenter.defaultCenter().postNotification(addFeatureSucceedNotification)

                }
            case .ExistedFeature(let title, let body):
                alertTitile = title
                alertBody = body
                needReEnterFeatureName = true
            case .MissingCover(let title, let body):
                alertTitile = title
                alertBody = body
            case .UnKnown(let title, let body):
                alertTitile = title
                alertBody = body
            }
            if alertTitile != nil && alertBody != nil{
                let alert = UIAlertController(title: alertTitile!, message: alertBody!, preferredStyle: .Alert)
                let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: {
                    action in
                    if needReEnterFeatureName{
                        self.featureNameTextField.becomeFirstResponder()
                    }
                })
                alert.addAction(okayAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
        
    }
    
    @IBAction func featureCoverTapped(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Add Cover for New Feature", message: nil, preferredStyle: .ActionSheet)
        
        let chooseExistingAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: { (action) -> Void in
            self.chooseFromLibarary()
        })
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (action) -> Void in
            self.takePhoto()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(takePhotoAction)
        alert.addAction(chooseExistingAction)
        alert.addAction(cancelAction)
        imagePickerUploadPhotoFor = UploadPhotoFor.featureCover
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    var featureCoverImage: UIImage?{
        didSet{
            featureCoverImageView?.image = featureCoverImage?.normalizedImage()
            cameraIcon?.hidden = true
            print(featureCoverImage)

        }
    }
    
    var featureName: String?
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        featureNameTextField.delegate = self
        self.navigationItem.rightBarButtonItem?.becomeStyleBarButtonItem()

        self.automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFeatureViewController.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFeatureViewController.keyBoardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        
        featureCoverHeightConstraint.constant = view.bounds.size.width / featureCoverAspectRatio
        
        if featureCoverImage != nil{
            featureCoverImageView.image =  featureCoverImage!.normalizedImage()
            cameraIcon.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //stretchy header set up
        self.globalScrollView = scrollView
        self.coverImageView = featureCoverImageView
        self.coverHeight =  featureCoverHeightConstraint.constant
        if featureCoverImage != nil{
            featureNameTextField.becomeFirstResponder()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if isKeyBoardActive && !isUIAdjustingWhileKeyBoardShows{
            view.endEditing(true)
        }
    }
    

    func keyboardDidShow(notification: NSNotification){
        if let keyboardFrame = notification.keyboardEndFrame{
            if let firstResponser = firstResponderObject{
                isUIAdjustingWhileKeyBoardShows = true
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
                let targetOriginFrameBottom = firstResponser.frame.origin.y + firstResponser.frame.size.height + self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
                let viewShouldScroll = max(targetOriginFrameBottom - (view.bounds.size.height - keyboardFrame.size.height - 10), 0)
                UIView.animateWithDuration(0.3, animations: {
                    self.scrollView.contentOffset.y = viewShouldScroll
                    }, completion: { finished in
                        self.isUIAdjustingWhileKeyBoardShows = false
                        self.isKeyBoardActive = true
                })
            }
            
        }
    }
    

    
    
    
    
    
    func keyBoardDidHide(notifcation: NSNotification){
        UIView.animateWithDuration(0.3, animations: {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }, completion: { finished in
                self.isKeyBoardActive = false
        })
    }
}

extension AddFeatureViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        featureNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        firstResponderObject = textField
    }
    
    
}