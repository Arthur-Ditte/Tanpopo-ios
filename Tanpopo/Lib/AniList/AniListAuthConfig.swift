// AniListAuthConfig.swift
struct AniListAuthConfig {
    static let clientID = "YOUR_CLIENT_ID" // Replace with your Client ID
    static let clientSecret = "YOUR_CLIENT_SECRET" // Replace with your Client Secret
    static let redirectURI = "myapp://auth" // Must match the redirect URI registered
    static let authorizationEndpoint = "https://anilist.co/api/v2/oauth/authorize"
    static let tokenEndpoint = "https://anilist.co/api/v2/oauth/token"
    static let scope = "read" // Define scopes as needed
}
