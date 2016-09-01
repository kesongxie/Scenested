//
//  DictionaryExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/10/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation

extension Dictionary{
    mutating func addDictionaryToCurrent(dictionary: Dictionary){
        for (key, value) in dictionary{
            self.updateValue(value, forKey: key)
        }
    }
}