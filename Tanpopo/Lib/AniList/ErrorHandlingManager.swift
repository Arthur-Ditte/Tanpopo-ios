import Foundation
import Combine

class ErrorHandlingManager: ObservableObject {
    static let shared = ErrorHandlingManager()
    
    @Published var errorMessage: String? = nil
    
    private init() {}
    
    func setError(_ message: String) {
        self.errorMessage = message
    }
    
    func clearError() {
        self.errorMessage = nil
    }
}