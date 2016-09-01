//
//  AddpostViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/21/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class EditPostViewController: StrechableHeaderViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var postCoverImageView: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    private var isKeyBoardActive: Bool = false //true when the keyboard is currently visible
    
    private var isUIAdjustingWhileKeyBoardShows: Bool = false //when the keyboard shows, the offset of the view will be adjusted based upon the frame of the keyboard, set to yes, if the View is on the process of adjusting the UI

    
    
    @IBOutlet weak var postCoverHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    
    @IBOutlet weak var sharePostBtn: UIBarButtonItem!
    
    
    @IBAction func sharePostBtnTapped(sender: UIBarButtonItem) {
        view.endEditing(true)
        self.navigationItem.title = "Sharing Post..."
        sender.enabled = false
        guard let postPhoto = postCoverImageView.image else{
            return
        }
        let postText = captionTextView.text ?? ""
        
        guard let featureId = feature?.id else{
            return
        }
        
        let textualInfo: [String: AnyObject] = [
            Feature.SharePostTextKey: postText,
            Feature.SharePostFeatureIdKey: featureId
        ]
        let images = [
            Feature.SharePostPhotoKey: postPhoto.normalizedImage()!
        ]
        
        
        let postInfo: [String: AnyObject] = [
            Feature.SharePostMediaKey: images,
            Feature.SharePostTextualInfoKey: textualInfo
        ]
       feature?.sharePost(postInfo, completionHandler: {
            (post, error) in
        
    
        if let tabBarVC = self.presentingViewController as? TabBarController{
            if let navigtionVC = tabBarVC.selectedViewController as? UINavigationController{
                tabBarVC.dismissViewControllerAnimated(true, completion: {
                    if let featureVC = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.FeatureViewControllerIden) as? FeatureViewController{
                        featureVC.feature = self.feature
                        featureVC.tableView.reloadData()
                        navigtionVC.pushViewController(featureVC, animated: true)
                    }
                    
                    //push a notification to reload feature for user
                })
            }
            
            
            
            

        }
    })
}
    
    
    @IBAction func postCoverTapped(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Add Photo for New Post", message: nil, preferredStyle: .ActionSheet)
        
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
        imagePickerUploadPhotoFor = UploadPhotoFor.postPicture
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private var firstResponderObject: AnyObject?
    
    var feature: Feature?{
        didSet{
            updatePostUIForAfterFeatureSet()
        }
    }
    
    var postImage: UIImage?{
        didSet{
            postCoverImageView.image = postImage
            if postImage != nil{
                captionTextView.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyShareButton()
        captionTextView.delegate = self
       sharePostBtn.becomeStyleBarButtonItem()
        
        self.automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditPostViewController.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditPostViewController.keyBoardWillHide), name: UIKeyboardWillHideNotification, object: nil) //good scrolling
        if feature != nil{
            updatePostUIForAfterFeatureSet()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        updateCoverView()
        verifyShareButton()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //stretchy header set up
        self.globalScrollView = scrollView
        self.coverImageView = postCoverImageView
        self.coverHeight =  postCoverHeightConstraint.constant
        self.stretchWhenContentOffsetLessThanZero = true
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
    
    

    //good scrolling
    func keyBoardWillHide(notifcation: NSNotification){
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        isKeyBoardActive = false
    }
    
    func updateCoverView(){
        if let coverImage = postCoverImageView.image{
            cameraIcon.hidden = true
            let imageSize = coverImage.size
            postCoverHeightConstraint.constant = view.bounds.size.width * imageSize.height  /  imageSize.width
        }

    }
    
    
    func updatePostUIForAfterFeatureSet(){
        if feature != nil{
            self.title = feature?.featureName.uppercaseString
            placeHolderLabel?.text = "What's new about your " + feature!.featureName.lowercaseString
        }
    }
    
    //change the style fo the share button based on the return of isPostSharable
    func verifyShareButton(){
        sharePostBtn.enabled = isPostSharable()
    }
    
    func isPostSharable() -> Bool{
        return coverImageView?.image != nil
    }
    
}

extension EditPostViewController: UITextViewDelegate{
    func textViewShouldReturn(textView: UITextView) -> Bool {
        captionTextView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        firstResponderObject = textView
    }
    
    func textViewDidChange(textView: UITextView) {
        placeHolderLabel.hidden = !textView.text.isEmpty
    }
    
}