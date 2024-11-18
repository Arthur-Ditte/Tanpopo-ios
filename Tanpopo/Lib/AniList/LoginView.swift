// LoginView.swift

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager = AniListAuthManager.shared
    
    var body: some View {
        VStack {
            if authManager.isAuthenticated {
                if let user = authManager.user {
                    UserProfileView(user: user)
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    ProgressView("Fetching User Data...")
                        .padding()
                }
            } else {
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
        .alert(isPresented: Binding<Bool>(
            get: { authManager.errorMessage != nil },
            set: { _ in authManager.errorMessage = nil }
        )) {
            Alert(title: Text("Error"),
                  message: Text(authManager.errorMessage ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
}
