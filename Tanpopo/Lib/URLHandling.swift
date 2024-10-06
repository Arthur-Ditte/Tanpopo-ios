//
//  URLHandlingError.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//


import Foundation
import SwiftUI

enum URLHandlingError: Error {
    case invalidURL
    case tokenExtractionFailed
}

struct URLHandler {
    static func handleRedirect(url: URL) -> Result<String, Error> {
        guard url.scheme == "tanpopo", url.host == "auth" else {
            return .failure(URLHandlingError.invalidURL)
        }

        if let fragment = url.fragment,
           let token = extractToken(fromFragmentString: fragment) {
            UserDefaults.standard.set(token, forKey: "accessToken")
            return .success(token)
        } else {
            return .failure(URLHandlingError.tokenExtractionFailed)
        }
    }

    private static func extractToken(fromFragmentString fragmentString: String) -> String? {
        let parameters = fragmentString.split(separator: "&")
        
        for parameter in parameters {
            let keyValue = parameter.split(separator: "=")
            if keyValue.count == 2 && keyValue[0] == "access_token" {
                return String(keyValue[1])
            }
        }
        
        return nil
    }
}