//
//  UIBarButtonItemExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/14/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit


extension UIBarButtonItem{
    func becomeStyleBarButtonItem(){
       self.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17, weight: UIFontWeightMedium), NSForegroundColorAttributeName: StyleSchemeConstant.themeColor ] , forState: .Normal)

    }

}