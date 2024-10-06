//
//  UserAuth.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//


import SwiftUI
import Combine

class UserAuth: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = "Guest"
    @Published var userAvatar: URL?
    
    func logIn() {
        // Handle login logic
        isLoggedIn = true
    }
    
    func logOut() {
        // Handle logout logic
        isLoggedIn = false
    }
}
