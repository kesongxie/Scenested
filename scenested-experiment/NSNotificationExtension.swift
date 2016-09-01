//
//  NSNotificationExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/14/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification{
    var keyboardEndFrame: CGRect?{
        return (self.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
    }

}