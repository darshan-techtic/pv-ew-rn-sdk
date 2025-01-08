//  PVSecureEnclave.swift
//  Created by techtic on 02/01/25.

import Foundation
import LocalAuthentication

enum secureEnclaveKeyType {
    case Signature
    case Encryption
}

class PVSecureEnclave {
    
    static let shared = PVSecureEnclave()
    
    private init(){}
        
    func clearData() {
    }
    
    func getSignatureKeyName(email: String) -> String {
        return "sig_\(email)"
    }
    
    func getEncryptionKeyName(email: String) -> String {
        return "enc_\(email)"
    }
    
    func showPublicKey(key: SecKey, keyType: secureEnclaveKeyType) -> String {
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            print("[SecureEnclaveHelper] \(keyType) Public Key => none")
            return ""
        }
        var error: Unmanaged<CFError>?
        if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
            print("[SecureEnclaveHelper] \(keyType) Public Key => is not none")
            return keyData.toHexString()
        } else {
            print("[SecureEnclaveHelper] \(keyType) Public Key => none")
            return ""
        }
    }
    
    func removeKey(email: String, keyType: secureEnclaveKeyType) {
        let keyName = (keyType == .Signature) ? getSignatureKeyName(email: email) : getEncryptionKeyName(email: email)
        PVKeychain.removeKey(name: keyName)
    }
    
    func prepareKey(email: String, keyType: secureEnclaveKeyType, useBiometry: Bool) -> SecKey? {
        print("[SecureEnclaveHelper] Preparing key with biometry \(useBiometry)")
        let keyName = (keyType == .Signature) ? getSignatureKeyName(email: email) : getEncryptionKeyName(email: email)
        if let existingKey = PVKeychain.loadKey(name: keyName) {
            return existingKey
        } else {
            do {
                let newKey = try PVKeychain.makeAndStoreKey(name: keyName, requiresBiometry: useBiometry)
                return newKey
            } catch let error {
                print("[SecureEnclaveHelper] \(keyType) Can't create key => " + error.localizedDescription)
                return nil
            }
        }
    }

    func sign(email: String, keyType: secureEnclaveKeyType, algorithm: SecKeyAlgorithm, data: Data, completionHandler: @escaping ((_ isSuccess: Bool, _ signature: Data?) -> Void)) {
        // Prepare the key on the fly
        let currentType = LAContext().biometricType
        var useBiometry = false
        if currentType.rawValue == "faceID" || currentType.rawValue == "touchID" {
            useBiometry = true
        }
        print("[SecureEnclaveHelper] Current biometric type: \(currentType), useBiometry: \(useBiometry)")
        
        guard let key = prepareKey(email: email, keyType: keyType, useBiometry: useBiometry) else {
            completionHandler(false, nil)
            return
        }
        print("[SecureEnclaveHelper] Prepared key")
        
        // Check if the algorithm is supported
        guard SecKeyIsAlgorithmSupported(key, .sign, algorithm) else {
            print("[SecureEnclaveHelper] \(keyType) Can't sign => Algorithm not supported")
            completionHandler(false, nil)
            return
        }

        // Perform the signing operation
        DispatchQueue.global().async {
            var error: Unmanaged<CFError>?
            if let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as Data? {
                DispatchQueue.main.async {
                    // Success
                    let signatureHex = signature.toHexString()
                    print("[SecureEnclaveHelper] \(keyType) Signature Digit --> " + signatureHex)
                    completionHandler(true, signature)
                }
            } else {
                DispatchQueue.main.async {
                    // Failure
                    if let error = error?.takeRetainedValue() {
                        print("[SecureEnclaveHelper] \(keyType) Can't sign => " + error.localizedDescription)
                    }
                    completionHandler(false, nil)
                }
            }
        }
    }
}

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
        case opticID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .opticID:
                return .opticID
            @unknown default:
                return .none
            }
        } else {
            return self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

// MARK: - Extensions
extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
  public func toHexString() -> String {
    return reduce("", {$0 + String(format: "%02X ", $1)})
  }
}
