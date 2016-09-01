//
//  LogInViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/2/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    
    

    @IBOutlet weak var loginIdenTextField: UITextField!
    
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!{
        didSet{
            loginBtn.layer.cornerRadius = 4.0
            loginBtn.layer.borderColor = UIColor.whiteColor().CGColor
            loginBtn.layer.borderWidth = 1.0
        }

    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func loginBtnTapped(sender: UIButton) {
        adjustProceedBtnUI(ProceedBtnStatus.BtnShouldLoadWithInterationDisabled, btn: self.loginBtn, btnInitialTitle: self.loginBtnInitialStateTitle, activityIndicator: self.activityIndicator)
        
        view.endEditing(true)
        guard let iden = loginIdenTextField.text else{
            return
        }
        guard let password = loginPasswordTextField.text else{
            return
        }
        
        User.authenticateUserByIdenAndPassword(iden, password: password, completionHandler: {
            (succeed, userId, error) in
            if succeed && userId != nil{
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser = User(id: userId!, completionHandler: {
                (successLogin, info) in
                    if successLogin{
                        User.saveUserCredentialToKeyChain(userId!, password: password)
                        self.presentTabBarViewController()
                    }
                })
            }else{
                if error != nil{
                    var alertTitle: String?
                    var alertBody: String?
                    switch error!{
                    case .IncorrectPassword(let title, let body):
                        alertTitle = title
                        alertBody = body
                    case .NoInternetConnection(let title, let body):
                        alertTitle = title
                        alertBody = body
                    case .Unknown(let title, let body):
                        alertTitle = title
                        alertBody = body
                    }
                    let alert = UIAlertController(title: alertTitle, message: alertBody, preferredStyle: .Alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                    alert.addAction(okayAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                
                    adjustProceedBtnUI(ProceedBtnStatus.BtnStopLoadingWithInterationEnabled, btn: self.loginBtn, btnInitialTitle: self.loginBtnInitialStateTitle, activityIndicator: self.activityIndicator)
                }
                
                
            }
        })
    }
    
    private let loginBtnInitialStateTitle = "Login"
    
    private var scrollViewOffSetWhenKeyBoardShowed: CGFloat = 40.0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.viewTapped(_:)))
        view.addGestureRecognizer(viewTapGesture)

        
        loginIdenTextField.delegate = self
        loginPasswordTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyBoardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogInViewController.keyBoardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        
        
        
        loginIdenTextField.addTarget(self, action: #selector(LogInViewController.textFieldEditing(_:)), forControlEvents: .EditingChanged)
        loginPasswordTextField.addTarget(self, action: #selector(LogInViewController.textFieldEditing(_:)), forControlEvents: .EditingChanged)
        
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    func textFieldEditing(textField: UITextField){
        loginable()
    }
    
    
    func loginable(){
        func disableLogin(){
            loginBtn.alpha = 0.6
            loginBtn.userInteractionEnabled = false
        }
        
        func enableLogin(){
            loginBtn.alpha = 1
            loginBtn.userInteractionEnabled = true
        }
        if loginIdenTextField.text == nil || loginPasswordTextField.text == nil{
            disableLogin()
        }else if loginIdenTextField.text!.isEmpty || loginPasswordTextField.text!.isEmpty{
           disableLogin()
        }else{
            enableLogin()
        }
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
    
    
    func viewTapped(gesture: UITapGestureRecognizer){
        view.endEditing(true)
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



extension LogInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loginable()
        
        if textField == loginIdenTextField{
            if (loginPasswordTextField.text == nil || loginPasswordTextField.text!.isEmpty){
                loginPasswordTextField.becomeFirstResponder()
            }
        }
        return true
    }
}





