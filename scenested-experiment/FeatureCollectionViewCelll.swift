//
//  featureCollectionViewCell.swift
//  scenested-experiment
//
//  Created by Xie kesong on 4/29/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class FeatureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var featureImage: FeatureImageView!
    
    @IBOutlet weak var featureName: UILabel!
    
    var feature: Feature?{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        featureImage?.image = nil
        featureName?.text = nil
        
        if let feature = self.feature{
            self.featureName.text = feature.featureName.uppercaseString
            featureImage.loadImageWithUrl(feature.coverPhoto.url)
            
//            guard let cacheKey = getCacheKeyForType(feature.imageUrlHash, cacheType: CacheType.CacheForFeatureCover) else{
//                return
//            }
//            
//            if let cacheCover = getGlobalCache()!.objectForKey(cacheKey) as? UIImage{
//                featureImage.image = cacheCover
//            }else{
//                 //fetch the image from the server
//                let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
//                dispatch_async(queue, {
//                    let url = feature.imageUrl
//                    if let url = NSURL(string: url){
//                        if let imageData = NSData(contentsOfURL: url){
//                            dispatch_async(dispatch_get_main_queue(), {
//                                //perform UI related task
//                                if let image = UIImage(data: imageData){
//                                    self.featureImage.image = image
//                                    getGlobalCache()!.setObject(image, forKey: cacheKey)
//                                }
//                            })
//                        }
//                    }
//                })
//            }
        }
        
       
        
       
    }

  
    

}
