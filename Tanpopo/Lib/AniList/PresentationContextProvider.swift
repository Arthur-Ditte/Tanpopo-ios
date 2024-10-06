//
//  PresentationContextProvider.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//

import AuthenticationServices
import Foundation


// MARK: - PresentationContextProvider

class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        // iOS-specific code
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
        #elseif os(macOS)
        // macOS-specific code
        return NSApplication.shared.windows.first!
        #endif
    }
}
