// LoginView.swift
import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager = AniListAuthManager.shared
    @EnvironmentObject var userSession: UserSession
    
    
    
    var body: some View {
        VStack {
            if authManager.isAuthenticated {
                // If authentication is successful, check for user data
                if let user = userSession.user {
                    UserProfileView(user: user)
                    
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    // Indicate that user data is still being fetched
                    ProgressView("Fetching User Data...")
                        .padding()
                }
            } else {
                // If not authenticated, show login button
                Button(action: {
                    authManager.startAuthentication()
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                        Text("Login with AniList")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .onAppear {
            debugLoginState()
        }
        .alert(isPresented: Binding<Bool>(
            get: { authManager.errorMessage != nil },
            set: { _ in authManager.errorMessage = nil }
        )) {
            Alert(title: Text("Error"),
                  message: Text(authManager.errorMessage ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to handle print statements for debugging
    private func debugLoginState() {
        if authManager.isAuthenticated {
            print("User is authenticated")
            if let user = userSession.user {
                print("User data: \(user)")
            } else {
                print("User data is being fetched")
            }
        } else {
            print("User is not authenticated")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock user for the preview
        let mockUser = User(id: 123, name: "Test User", avatar: User.Avatar(large: "https://example.com/avatar.jpg"))
        
        // Create a mock UserSession
        let mockUserSession = UserSession(user: mockUser)
        
        let authManager = AniListAuthManager.shared
        authManager.isAuthenticated = true
        
        // Provide the mock UserSession to the environment
        return LoginView()
            .environmentObject(mockUserSession)

            .preferredColorScheme(.light) // Inject the mock session into the environment
    }
}
