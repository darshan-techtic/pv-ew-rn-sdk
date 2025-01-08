//  PVWebAPIModel.swift
//  Created by Techtic on 13/12/24.

import Foundation
import UIKit
import LocalAuthentication

public struct APIRequest {
    static let isBackupActive = "https://test.excheqr.xyz/api/investment/vault_backup/is_backup_active"
}

@objc(PVWebAPIModel)
class PVWebAPIModel: NSObject {

    @objc public func getSigningKey(
        _ email: String,
        callback:RCTResponseSenderBlock) {        
        let currentType = LAContext().biometricType
        var useBiometry = false
        if currentType.rawValue == "faceID" || currentType.rawValue == "touchID" {
            useBiometry = true
        }
        if let generatedSignatureKey = PVSecureEnclave.shared.prepareKey(email: email, keyType: .Signature, useBiometry: useBiometry) {
            var signingKey = PVSecureEnclave.shared.showPublicKey(key: generatedSignatureKey, keyType: .Signature)
            print("[SecureEnclaveHelper] Signing Key => \(signingKey)")
            callback([signingKey])
        } else {
            callback(["Error: Unable to generate signing key"])
        }
    }
    
   @objc public func isBackupActive(_ userId:String, orgId:String, completionHandler: @escaping ((_ isSuccess: Bool) -> Void)) {
             print("userId URL: \(userId)")

      let serviceManager = PVServiceManager<BackupActiveStatus>()
       let endPoint = "\(APIRequest.isBackupActive)?userId=\(userId)&orgId=\(orgId)"
       print("Endpoint URL: \(endPoint)")
       
       serviceManager.webServiceAPICall(endpoint: endPoint, httpMethod: .get, params: [:], loaderEnabled: true) { (result: Result<BackupActiveStatus, PVErrorType>) in
           if let response = try? result.get() {
               if response.isBackupActive == true {
                   completionHandler(true)
               } else {
                   completionHandler(false)
               }
           }
       }
   }
}
