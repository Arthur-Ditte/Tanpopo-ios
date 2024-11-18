// KeychainHelper.swift

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    /// Saves data to the Keychain.
    /// - Parameters:
    ///   - data: The data to save.
    ///   - service: A string that identifies your service.
    ///   - account: A string that identifies the account.
    func save(_ data: Data, service: String, account: String) {
        // Create query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecValueData as String   : data
        ]
        
        // Add data to Keychain
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Reads data from the Keychain.
    /// - Parameters:
    ///   - service: A string that identifies your service.
    ///   - account: A string that identifies the account.
    /// - Returns: The data if found, else `nil`.
    func read(service: String, account: String) -> Data? {
        // Create query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    /// Deletes data from the Keychain.
    /// - Parameters:
    ///   - service: A string that identifies your service.
    ///   - account: A string that identifies the account.
    func delete(service: String, account: String) {
        // Create query
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]
        
        // Delete item from Keychain
        SecItemDelete(query as CFDictionary)
    }
}
