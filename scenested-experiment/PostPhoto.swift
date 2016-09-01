//
//  PostPhoto.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/16/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

class PostPhoto: Photo{
    var aspectRatio: CGFloat?
    init(url: String, hash: String, aspectRatio: CGFloat){
        super.init(url: url, hash: hash)
        self.aspectRatio = aspectRatio
    }
}