//
//  WelcomeViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/5/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
//import AWSCognitoIdentityProvider

class WelcomeViewController: UIViewController {

    
    var fbLoginBtn: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        button.frame.size = CGSize(width: 190, height: 40)
        return button
    }()
    
     let myIdentityPoolId = "us-east-1:ed610da8-bd94-4968-afc9-129b7c17516d"
    
    
    
    @IBAction func segueToWelcomeVC(unWindSegue: UIStoryboardSegue){
    
    }
    
   var credentialsProvider:AWSCognitoCredentialsProvider?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginBtn.center = self.view.center
        fbLoginBtn.delegate = self
        view.addSubview(fbLoginBtn)
        // Do any additional setup after loading the view.
        
        //AWSIdentityProviderManager
        if let token = FBSDKAccessToken.currentAccessToken()?.tokenString{
            let customProviderManager = CredentialProvider(tokens: [AWSIdentityProviderFacebook: token])
            let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: .USEast1,
                identityPoolId: myIdentityPoolId,
                identityProviderManager: customProviderManager
            )
            let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
          
           //my class has to keep a reference to our credential provider
            self.credentialsProvider = credentialsProvider
            self.credentialsProvider?.getIdentityId().continueWithBlock({
                block in
                    let imageUrl = NSBundle.mainBundle().URLForResource("tennis", withExtension: "jpg")

                    let uploadRequest = AWSS3TransferManagerUploadRequest()
                    uploadRequest.body = imageUrl
                    uploadRequest.key = "picture" //this just the filename you will store at the s3
                    uploadRequest.bucket = "scenested-m"
                    uploadRequest.contentType = "image/jpeg"
                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                    // Perform file upload
                    transferManager.upload(uploadRequest).continueWithBlock{
                        (task) -> AnyObject! in
                        if task.error != nil{
                            print("error uploading \(task.error?.localizedDescription)")
                        }else{
                            print("upload succeed")
                        }
                        return nil
                    }
                return nil
            })
        }
    }
    
    func fetchProfile(){
        let param = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest.init(graphPath: "me", parameters: param).startWithCompletionHandler({
            (connection ,user, error) in
            if error != nil{
                    print(error)
                return
            }
            guard let user = user as? [String: AnyObject] else{
                return
            }
            
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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

extension WelcomeViewController: FBSDKLoginButtonDelegate{
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        if error != nil{
//            print("canceled")
//            return
//        }
//        fetchProfile()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("did log out")
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}
