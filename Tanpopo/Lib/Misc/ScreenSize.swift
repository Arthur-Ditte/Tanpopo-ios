import SwiftUI

struct ScreenSize {
    /// Returns the screen width based on the platform.
    static var width: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.width
        #elseif os(macOS)
        return NSScreen.main?.frame.width ?? 800 // Default to 800 if screen is unavailable
        #else
        return 800 // Default fallback for unsupported platforms
        #endif
    }
    
    /// Returns the screen height based on the platform.
    static var height: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.height
        #elseif os(macOS)
        return NSScreen.main?.frame.height ?? 600 // Default to 600 if screen is unavailable
        #else
        return 600 // Default fallback for unsupported platforms
        #endif
    }
}