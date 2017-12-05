//
//  SwampAuthMethod.swift
//  SwampFramework
//
//  Created by Eli Burke on 10/25/16.
//

import Foundation

public enum WampAuthMethod : String {
    case ticket = "ticket"              // plaintext
    case cra = "wampcra"                // hmac
    case tls = "tls"                    // ???
    case cryptosign = "cryptosign"      // ??? 
}
