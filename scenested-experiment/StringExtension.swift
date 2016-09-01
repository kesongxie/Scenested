//
//  StringExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 7/22/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

extension String{
    var characterCount:Int{
        return (self as NSString).length
    }
    
    
    func fullRange() -> NSRange{
        let stringInfo = "{0, \((self as NSString).length)}"
        return NSRangeFromString(stringInfo)
    }
    
    
    
}