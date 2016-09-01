//
//  SignUpUserNamePasswordViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/7/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class SignUpUserNamePasswordViewController: MediaResponseViewController {
    @IBOutlet weak var avatorImageView: UIImageView!{
        didSet{
            avatorImageView.becomeCircleAvator()
            avatorImageView.clipsToBounds = true
        }
    }

    @IBOutlet weak var signUpUserNameTextField: UITextField!
    
    @IBOutlet weak var signUpPasswordTextField: UITextField!
    
    
    @IBOutlet weak var signUpBtn: UIButton!{
        didSet{
            signUpBtn.layer.cornerRadius = 4.0
            signUpBtn.layer.borderColor = UIColor.whiteColor().CGColor
            signUpBtn.layer.borderWidth = 1.0
        }

    }
    
    private let signUpBtnInitialStateTitle = "Sign Up"
    
    @IBOutlet weak var signUpCancelBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    @IBAction func signUpBtnTapped(sender: UIButton) {
        adjustProceedBtnUI(ProceedBtnStatus.BtnShouldLoadWithInterationDisabled, btn: self.signUpBtn, btnInitialTitle: self.signUpBtnInitialStateTitle, activityIndicator: self.activityIndicator)
        view.endEditing(true)
        //sign up the user
        var registerInfo = [String: AnyObject]()
        guard let username = signUpUserNameTextField.text else{
            //alert username error
            print("username invalid")
            return
        }
        
        guard let email = signUpEmailString else{
            print("email invalid")
            return
        }
        
        guard let fullname = signUpFullNameString else{
            print("fullname invalid")
            return
        }
        
        guard let password = signUpPasswordTextField.text else{
            print("password invalid")
            return
        }
        guard let avator = avatorImage else{
            print("avator invalid")
            return
        }
        
        //check whether the username has been used or not
        User.checkUserForUsernameExists(signUpUserNameTextField.text!, completionHandler: {
            (exists) in
            if !exists {
                registerInfo[UserRegistrationLocalizedString.InfoUsernameKey] = username
                registerInfo[UserRegistrationLocalizedString.InfoEmailKey] = email
                registerInfo[UserRegistrationLocalizedString.InfoFullnameKey] = fullname
                registerInfo[UserRegistrationLocalizedString.InfoPasswordKey] = password
                let mediaDataInfo = [UserRegistrationLocalizedString.InfoAvatorKey:  avator]
                User.register(mediaInfo: mediaDataInfo, textualInfo: registerInfo, completionHandler: {
                    (registeredSucceed, resgistedUserInfo) in
                    if registeredSucceed && resgistedUserInfo != nil{
                        if let userId = resgistedUserInfo!["userId"] as? Int{ //the user id for the user registered user
                            User.saveUserCredentialToKeyChain(userId, password: password)
                            setLoggedInUser(userId, completionHandler: {
                                (succeed, info) in
                                if succeed{
                                    self.presentTabBarViewController()
                                }
                            })
                        }
                    }
                    //navigate to a logged-in scene after sign up, save the user info to user default, so the next time the user does not need to log in again
                })
            }else{
                adjustProceedBtnUI(ProceedBtnStatus.BtnStopLoadingWithInterationEnabled, btn: self.signUpBtn, btnInitialTitle: self.signUpBtnInitialStateTitle, activityIndicator: self.activityIndicator)
                let alert = UIAlertController(title: "Username Invalid", message: "The username has been used", preferredStyle: .Alert)
                let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(okayAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func signUpCancelBtnTapped(sender: UIButton) {
        
    }
    
    var avatorImage: UIImage?{
        didSet{
            avatorImageView?.image = avatorImage
        }
    }
    
    var signUpEmailString: String?{
        didSet{
            print("Sign Up Email Set")
        }
    }
    var signUpFullNameString: String?{
        didSet{
            print("Sign Up fullname Set")
        }

    }
    
    
    
    private var scrollViewOffSetWhenKeyBoardShowed: CGFloat = 40.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if avatorImage != nil{
            avatorImageView?.image = avatorImage
        }
        
        
        self.navigationController?.navigationBarHidden = true
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpUserNamePasswordViewController.viewTapped(_:)))
    
        view.addGestureRecognizer(viewTapGesture)
 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpUserNamePasswordViewController.keyBoardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpUserNamePasswordViewController.keyBoardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        
        
        signUpUserNameTextField.addTarget(self, action: #selector(SignUpUserNamePasswordViewController.textFieldEditing), forControlEvents: .EditingChanged)
        
        signUpPasswordTextField.addTarget(self, action: #selector(SignUpUserNamePasswordViewController.textFieldEditing), forControlEvents: .EditingChanged)
        
        signUpUserNameTextField.delegate = self
        signUpPasswordTextField.delegate = self
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return.LightContent
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
    
    
    func textFieldEditing(){
        //validation
        isAllowedToSignUp()
    }
    
    func isAllowedToSignUp(){
        if signUpUserNameTextField.text == nil || signUpPasswordTextField.text == nil{
            signUpBtn.alpha = 0.6
            signUpBtn.userInteractionEnabled = false
            return
        }
        let (usernameValid, _) = isUserNameValid(signUpUserNameTextField.text!)
        let (passwowrdValid, _) = isPasswordValid(signUpPasswordTextField.text!)
        let signUpAvatorNotEmpty = (avatorImage != nil)
        if usernameValid && passwowrdValid && signUpAvatorNotEmpty{
            signUpBtn.alpha = 1.0
            signUpBtn.userInteractionEnabled = true
        }else{
            signUpBtn.alpha = 0.6
            signUpBtn.userInteractionEnabled = false
        }
    }
    
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SignUpUserNamePasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isAllowedToSignUp()
        if textField == signUpUserNameTextField{
            if (signUpPasswordTextField.text == nil || signUpPasswordTextField.text!.isEmpty){
                signUpPasswordTextField.becomeFirstResponder()
            }
        }
        return true
    }
}