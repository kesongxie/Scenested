//
//  CredentialProvider.swift
//  scenested
//
//  Created by Xie kesong on 10/21/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider


class CredentialProvider:NSObject, AWSIdentityProviderManager {
    var tokens : [NSString : NSString]?
    
    
    
    init(tokens: [NSString : NSString]) {
        self.tokens = tokens
        
    }
    @objc func logins() -> AWSTask {
        return AWSTask(result: tokens)
    }
}
