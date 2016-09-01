//
//  HttpRequest.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/31/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//
//  class HttpRequest provide a interface for sending HTTP request
//

import Foundation
import Alamofire



class HttpRequest{
    var requestPath: String //the root path for the request to the server
    var httpMethod: String = "POST" //default is post
    var parameterInfo: [String: AnyObject]? //needed for adding any parameter

    
    //key for the parameter that send to the server
    struct SupportedParamKey{
        static let userId = "userId"
        static let avator = "avator"
        static let cover = "cover"
        static let post = "post"
        static let username = "username"
        static let password = "password"
        static let fullname = "fullname"
        static let bio = "bio"
        static let profileVisible = "profileVisible"
        static let info = "info"
    }
    
    //no http parameter
    init(requestPath: String){
        self.requestPath = requestPath
    }
    
    //with required parameterInfo
    init(requestPath: String, parameterInfo: [String: AnyObject]){
        self.requestPath = requestPath
        self.parameterInfo = parameterInfo
    }
    
    //perform the dataTask with corresponding url
    //callBack is optional
    func send(completionHandler callBack: ((respondData: [String: AnyObject]) -> Void)?){
        //request url is a parameter needs to pass in
        let requestUrl = NSURL(string: requestPath)
        let request = NSMutableURLRequest(URL: requestUrl!)
        //construct the parameter string based on a dictionary
        if parameterInfo != nil{
            var postString = ""
            for (parameterSeverSideKey, parameterSeverSideValue) in parameterInfo!{
                postString += "\(parameterSeverSideKey)=\(parameterSeverSideValue)&"
            }
            postString = postString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&"))
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        request.HTTPMethod = httpMethod
        //default httpMethod is Post
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            //turn the NSData to a jason object
            if (response as? NSHTTPURLResponse)?.statusCode == 200{
                do{
                    
                    if let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]{
                        if callBack != nil{
                            callBack!(respondData: jsonObject)
                        }
                    }
                }catch{
                    let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(str)
                }
            }
            NSURLSession.sharedSession().finishTasksAndInvalidate()
        }).resume()
    }
    
    
    
    static func sendRequest(requestUrl: String, method: Alamofire.Method, param:[String: AnyObject]?, completionHandler: (response: AnyObject?, error: String?) -> Void ){
        Alamofire.request(method, requestUrl, parameters: param, encoding: .URLEncodedInURL, headers: nil).validate().response(completionHandler: {
                (request, response, data, e) in
            
            //let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
           // print(str)
                if data != nil{
                    do{
                        if let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject]{
                            if jsonObject["statusCode"] as! Int == 200{
                                completionHandler(response: jsonObject["info"], error: nil)
                            }
                        }
                    }catch{
                        completionHandler(response: nil, error: e?.localizedDescription)
                        let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print(str)
                        
                    }
                }
        })
        
    }
    
    /*
        images: key are defined in SupportedParamKey struct, values are UIImage
        param: additional information for the images, key are defined in SupportedParamKey struct
     */
    
    static func uploadImagesWithUserInfo(requestUrl: String, images: [String: UIImage]?, param: [String: AnyObject]?, completionHandler: (response: [String: AnyObject]?, error: String?) -> Void ){
     
        var parameterJSON: NSData?
        do{
            if let userInfo = param{
                parameterJSON = try NSJSONSerialization.dataWithJSONObject(userInfo, options: .PrettyPrinted)
            }
        }catch{
            print("invalid parameter")
            return
        }
        
        Alamofire.upload(
            .POST,
            requestUrl,
            multipartFormData: { multipartFormData in
                //construct the user info param
                multipartFormData.appendBodyPart(data: parameterJSON!, name: SupportedParamKey.info)
                //construct the image data
                if let imagesToBeUploaded = images{
                    for (imageAssociateTypeName, image) in imagesToBeUploaded{
                        if let imageData = UIImageJPEGRepresentation(image, 0.8){
                            multipartFormData.appendBodyPart(data: imageData, name: imageAssociateTypeName, fileName: imageAssociateTypeName + ".jpg", mimeType: "image/jpg")
                        }
                    }
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                         if response.data != nil{
                          //  let str = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
//                            print(str)
                            do{
                                if let jsonObject = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as? [String: AnyObject]{
                                    print(jsonObject)
                                    completionHandler(response: jsonObject, error: nil)
                                }
                            }catch{
                                completionHandler(response: nil, error: "failed to perform json serialization")
                                let str = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
                                print(str)
                                
                            }
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    print("what is no long")
                    completionHandler(response: nil, error: "Request Failed")
                }
            }
        )

    
    
    
    
    }
    
    
    
    
    
    
    
    
    
}