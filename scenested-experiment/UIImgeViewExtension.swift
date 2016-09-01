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
    
    func loadImageWithUrl(url: String?, imageUrlHash: String?, cacheType: CacheType){
        
        
        
        guard let url = url else{
            return
        }
        
//        guard let imageUrlHash = imageUrlHash else{
//            return
//        }
        
        
        let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
        
        self.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: {
            (request, response, image) in
            self.image = image
            }, failure: {
            (request, respone, error) in
        })

        
        
        
        
        
        
//
//        guard let cacheKey = getCacheKeyForType(imageUrlHash, cacheType: cacheType) else{
//            return
//        }
//        
//        if let cacheCover = getGlobalCache()!.objectForKey(cacheKey) as? UIImage{
//            self.image = cacheCover
//            getGlobalCache()!.setObject(cacheCover, forKey: cacheKey)
//        }else{
//            //fetch the image from the server
//            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
//            dispatch_async(queue, {
//                if let url = NSURL(string: url){
//                    if let imageData = NSData(contentsOfURL: url){
//                        dispatch_async(dispatch_get_main_queue(), {
//                            //perform UI related task
//                            if let image = UIImage(data: imageData){
//                                self.image = image
//                                getGlobalCache()!.setObject(image, forKey: cacheKey)
//                                
//                            }
//                        })
//                    }
//                }
//            })
//        }
    }
    
    
    
       
    
    
}