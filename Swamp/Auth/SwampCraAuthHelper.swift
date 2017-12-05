//
//  WampCraAuthHelper.swift
//  Pods
//
//  Created by Yossi Abraham on 31/08/2016.
//
//

import Foundation
import Security
import CommonCrypto

// NOTE: until there a better solution, here is how to add CommonCrypto without ObjC wrappers
// http://stackoverflow.com/questions/25248598/importing-commoncrypto-in-a-swift-framework
// Here are swift wrappers for many CommonCrypto functions for reference purposes
// https://github.com/iosdevzone/IDZSwiftCommonCrypto

open class SwampCraAuthHelper {
    
    open static func compute_wcs(key: String, challenge: String) -> String {
        var output = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        let keyBytes = key.utf8.map {$0}
        let challengeBytes = challenge.utf8.map {$0}
        
        let _ = output.withUnsafeMutableBytes {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, keyBytes.count, challengeBytes, challengeBytes.count, $0);
        }
        
        return output.base64EncodedString()
    }
    
    open static func derive_key(secret: String, salt: String, iterations: Int, keyLen: Int) -> String {

        var output = Data(count: keyLen)
        let secretBytes = secret.utf8.map {$0}
        let saltBytes = salt.utf8.map {$0}
        
        let _ = output.withUnsafeMutableBytes {
            CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), secret, secretBytes.count, saltBytes, saltBytes.count,
                                 CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), UInt32(iterations), $0, keyLen)
        }
        return output.base64EncodedString()
    }
    
    open static func test_cra() {
        
        // plain, unsalted
        let foo = SwampCraAuthHelper.compute_wcs(key: "farside1", challenge: "workingforjimisfun")
        print("foo = \(foo) [should be lZa3t1YfOrFf9ooh/1SkgE8ccXOAs2MIYhVFmrff4us=]") // lZa3t1YfOrFf9ooh/1SkgE8ccXOAs2MIYhVFmrff4us=
        
        // salted
        var bar = SwampCraAuthHelper.derive_key(secret: "farside1", salt: "RRAbWAtgLnCw", iterations: 30000, keyLen: 32)
        bar = SwampCraAuthHelper.compute_wcs(key: bar, challenge: "workingforjimisfun")
        print("bar = \(bar) [should be 21lRNJpOCyD2DpjWW7E99M5H1hZ0EmsU1YEJNpjOoAE=]") // 21lRNJpOCyD2DpjWW7E99M5H1hZ0EmsU1YEJNpjOoAE
    }
    
/*
    open static func sign(_ secret: String, challenge: String) -> String {
        let hmac: Array<UInt8> = try! CryptoSwift.HMAC(key: secret.utf8.map {$0}, variant: .sha256).authenticate(challenge.utf8.map {$0})
        return hmac.toBase64()!
    }
 */
    
}


