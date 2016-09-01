//
//  Photo.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/13/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

class Photo{
    let url: String //url
    let hash: String //unique iden
    init(url: String, hash: String){
        self.url = url
        self.hash = hash
    }
}