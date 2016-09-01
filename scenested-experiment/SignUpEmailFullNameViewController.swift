//
//  SignUpEmailFullNameViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/2/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class SignUpEmailFullNameViewController: MediaResponseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    
    @IBOutlet weak var avatorImageView: UIImageView!{
        didSet{
            avatorImageView.becomeCircleAvator()
            avatorImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var signUpEmailTextField: UITextField!
    
    
    @IBOutlet weak var signUpFullNameTextField: UITextField!
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var proceedBtn: UIButton!{
        didSet{
            proceedBtn.layer.cornerRadius = 4.0
            proceedBtn.layer.borderColor = UIColor.whiteColor().CGColor
            proceedBtn.layer.borderWidth = 1.0
        }
    }
    
    private let proceedBtnInitialStateTitle = "Next"
//    
//    private enum ProceedBtnStatus{
//        case BtnShouldLoadWithInterationDisabled
//        case BtnStopLoadingWithInterationEnabled
//    }

    
    @IBAction func proceedBtnTapped(sender: UIButton) {
        adjustProceedBtnUI(ProceedBtnStatus.BtnShouldLoadWithInterationDisabled, btn: self.proceedBtn, btnInitialTitle: self.proceedBtnInitialStateTitle, activityIndicator: self.activityIndicator)
        view.endEditing(true)
        let (emailValid, error) = isEmailValid(signUpEmailTextField.text!)
        if signUpEmailTextField.text == nil || (signUpEmailTextField.text != nil && !emailValid){
            let alert = UIAlertController(title: "Invalid Email", message: error, preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(okayAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }else if avatorImage == nil{
            let alert = UIAlertController(title: "Profile Photo Needed", message: "Please add a photo for your profile", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(okayAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        //check whether the email has been used or not
        
        User.checkUserForEmailExists(signUpEmailTextField.text!, completionHandler: {
            exists in
            if !exists{
                if let signUpUsernamePasswordVC = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.SignUpUserNamePasswordViewControllerIden) as?SignUpUserNamePasswordViewController{
                        signUpUsernamePasswordVC.avatorImage = self.avatorImage
                        signUpUsernamePasswordVC.signUpEmailString = self.signUpEmailTextField.text
                        signUpUsernamePasswordVC.signUpFullNameString = self.signUpFullNameTextField.text
                    self.navigationController?.pushViewController(signUpUsernamePasswordVC, animated: true)
                }
            }else{
                adjustProceedBtnUI(ProceedBtnStatus.BtnStopLoadingWithInterationEnabled, btn: self.proceedBtn, btnInitialTitle: self.proceedBtnInitialStateTitle, activityIndicator: self.activityIndicator)
                let alert = UIAlertController(title: "Email Invalid", message: "The email has been used", preferredStyle: .Alert)
                let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(okayAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    
    var avatorImage: UIImage?{
        didSet{
            avatorImageView?.image = avatorImage
            if avatorImage != nil{
                cameraIcon.hidden = true
            }
            nextVerificationForEmailAndPasswordAndAvator()
        }
    }
    
    private var scrollViewOffSetWhenKeyBoardShowed: CGFloat = 40.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpEmailFullNameViewController.viewTapped(_:)))
        view.addGestureRecognizer(viewTapGesture)
        
        let avatorTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpEmailFullNameViewController.tapAvator(_:)))
        avatorImageView.addGestureRecognizer(avatorTapGesture)
        
        signUpEmailTextField.delegate = self
        signUpFullNameTextField.delegate = self
        scrollView.alwaysBounceVertical = true
      
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpEmailFullNameViewController.keyBoardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpEmailFullNameViewController.keyBoardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        
        
        signUpEmailTextField.addTarget(self, action: #selector(SignUpEmailFullNameViewController.textLabelEditing), forControlEvents: .EditingChanged)
        
        signUpFullNameTextField.addTarget(self, action: #selector(SignUpEmailFullNameViewController.textLabelEditing), forControlEvents: .EditingChanged)

        
        // Do any additional setup after loading the view.
    }
    
    
    
       
    
    // MARK:: Avator, Cover tap gesture configuration
    func tapAvator(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
        let chooseExistingAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: { (action) -> Void in
            self.chooseFromLibarary()
        })
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler:
            {(action) -> Void in
                self.takePhoto()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (action) -> Void in
            self.finishImagePicker()
        })
        alert.addAction(takePhotoAction)
        alert.addAction(chooseExistingAction)
        alert.addAction(cancelAction)
        imagePickerUploadPhotoFor = UploadPhotoFor.signUpAvator
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func viewTapped(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func keyBoardDidShow(){
        UIView.animateWithDuration(0.3, animations: {
            self.scrollView.contentOffset.y = self.scrollViewOffSetWhenKeyBoardShowed
        })
    }
    
    func keyBoardDidHide(){
        UIView.animateWithDuration(0.3, animations: {
            self.scrollView.contentOffset.y = 0
        })
    }
    
    
    func textLabelEditing(){
        nextVerificationForEmailAndPasswordAndAvator()
    }

    
    func nextVerificationForEmailAndPasswordAndAvator(){
        
        if signUpEmailTextField.text == nil || signUpFullNameTextField.text == nil{
            proceedBtn.alpha = 0.6
            proceedBtn.userInteractionEnabled = false
        }
        
        let (emailValid, _) = isEmailValid(signUpEmailTextField.text!)
        
        let (fullnameValid, _) = isFullNameValid(signUpFullNameTextField.text!)
       
        let signUpAvatorNotEmpty = (avatorImage != nil)
        
        if emailValid && fullnameValid && signUpAvatorNotEmpty{
            proceedBtn.alpha = 1.0
            proceedBtn.userInteractionEnabled = true
        }else{
            proceedBtn.alpha = 0.6
            proceedBtn.userInteractionEnabled = false
        }
    }
    

    //MARK: - Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let signUpUsernamePasswordVC = segue.destinationViewController as? SignUpUserNamePasswordViewController{
//            signUpUsernamePasswordVC.avatorImage = self.avatorImage
//            signUpUsernamePasswordVC.signUpEmailString = signUpEmailTextField.text
//            signUpUsernamePasswordVC.signUpFullNameString = signUpFullNameTextField.text
//        }
//    }
    
}

extension SignUpEmailFullNameViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextVerificationForEmailAndPasswordAndAvator()
        
        if textField == signUpEmailTextField{
            if (signUpFullNameTextField.text == nil || signUpFullNameTextField.text!.isEmpty){
                signUpFullNameTextField.becomeFirstResponder()
            }
        }
        return true
    }
 }


