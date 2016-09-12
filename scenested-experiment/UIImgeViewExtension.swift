//
//  ProfileGlobal.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/17/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking


extension UIImageView{
    func becomeCircleAvator(){
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 3
    }
    
    func loadImageWithUrl(url: String?){
        guard let url = url else{
            return
        }
        let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
        self.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: {
            (request, response, image) in
            self.image = image
            }, failure: {
            (request, respone, error) in
                print(error)
        })
    }
}
