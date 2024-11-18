// AniListAuthManager.swift

import AuthenticationServices
import SwiftUI
import Combine

class AniListAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AniListAuthManager()
    
    // Published properties to update the UI
    @Published var accessToken: String?
    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var errorMessage: String?
    
    // Private properties
    private var authSession: ASWebAuthenticationSession?
    private var cancellables = Set<AnyCancellable>()
    
    // Keychain keys
    private var accessTokenService: String { "AniListService" }
    private var accessTokenAccount: String { "accessToken" }
    
    override init() {
        super.init()
        loadAccessToken()
    }
    
    /// Starts the AniList OAuth authentication process.
    func startAuthentication() {
        // Construct the authorization URL
        var urlComponents = URLComponents(string: AniListAuthConfig.authorizationEndpoint)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AniListAuthConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: AniListAuthConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AniListAuthConfig.scope)
        ]
        
        guard let authURL = urlComponents.url else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid Authorization URL."
            }
            return
        }
        
        // Start ASWebAuthenticationSession
        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "myapp") { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                DispatchQueue.main.async {
                    self.errorMessage = "No callback URL received."
                }
                return
            }
            
            // Extract the authorization code
            guard let code = self.extractCode(from: callbackURL) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Authorization code not found."
                }
                return
            }
            
            // Exchange code for token
            self.exchangeCodeForToken(code: code)
        }
        
        // Explicitly cast self to 'any ASWebAuthenticationPresentationContextProviding'
        authSession?.presentationContextProvider = self as any ASWebAuthenticationPresentationContextProviding
        authSession?.start()
    }
    
    /// Extracts the authorization code from the callback URL.
    /// - Parameter url: The callback URL received after authentication.
    /// - Returns: The authorization code if found, else `nil`.
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        return code
    }
    
    /// Exchanges the authorization code for an access token.
    /// - Parameter code: The authorization code received from AniList.
    private func exchangeCodeForToken(code: String) {
        guard let tokenURL = URL(string: AniListAuthConfig.tokenEndpoint) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid Token URL."
            }
            return
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let params = [
            "grant_type": "authorization_code",
            "client_id": AniListAuthConfig.clientID,
            "client_secret": AniListAuthConfig.clientSecret,
            "redirect_uri": AniListAuthConfig.redirectURI,
            "code": code
        ]
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Token Exchange Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from token exchange."
                }
                return
            }
            
            // Parse the JSON response
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.accessToken = tokenResponse.access_token
                    self?.isAuthenticated = true
                    self?.saveAccessToken(tokenResponse.access_token)
                    self?.fetchCurrentUser()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to decode token response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    /// Fetches the authenticated user's data from AniList.
    private func fetchCurrentUser() {
        guard let accessToken = accessToken else { return }
        let query = """
        query {
          Viewer {
            id
            name
            avatar {
              large
            }
          }
        }
        """
        
        guard let url = URL(string: "https://graphql.anilist.co") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid GraphQL URL."
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "User Fetch Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from user fetch."
                }
                return
            }
            
            // Parse the JSON response
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(AniListUserResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.user = apiResponse.data.viewer
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to decode user response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // MARK: - Keychain Methods
    
    /// Loads the access token from the Keychain, if available.
    private func loadAccessToken() {
        if let data = KeychainHelper.shared.read(service: accessTokenService, account: accessTokenAccount),
           let token = String(data: data, encoding: .utf8) {
            self.accessToken = token
            self.isAuthenticated = true
            fetchCurrentUser()
        }
    }
    
    /// Saves the access token securely in the Keychain.
    /// - Parameter token: The access token to save.
    private func saveAccessToken(_ token: String) {
        if let data = token.data(using: .utf8) {
            KeychainHelper.shared.save(data, service: accessTokenService, account: accessTokenAccount)
        }
    }
    
    /// Deletes the access token from the Keychain.
    private func deleteAccessToken() {
        KeychainHelper.shared.delete(service: accessTokenService, account: accessTokenAccount)
    }
    
    // MARK: - Logout
    
    /// Logs out the user by clearing authentication data.
    func logout() {
        accessToken = nil
        isAuthenticated = false
        user = nil
        deleteAccessToken()
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    /// Provides the presentation anchor for `ASWebAuthenticationSession`.
    /// - Parameter session: The authentication session requesting the anchor.
    /// - Returns: The window to present the authentication session.
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        // Return the key window for iOS
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        #elseif os(macOS)
        // Return the main window for macOS
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
        #else
        return ASPresentationAnchor()
        #endif
    }
}

// MARK: - Codable Structures

/// Represents the response received after exchanging the authorization code for an access token.
struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
}

/// Represents the response received when fetching user data.
struct AniListUserResponse: Codable {
    let data: AniListViewer
}

/// Represents the viewer (authenticated user) in AniList.
struct AniListViewer: Codable {
    let viewer: User
}

/// Represents a user in AniList.
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let avatar: Avatar
}

/// Represents a user's avatar in AniList.
struct Avatar: Codable {
    let large: String
}
