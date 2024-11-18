//
//  NotLoggedInView.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 14.11.24.
//

import SwiftUI


struct NotLoggedInView: View {
    var body: some View {
        ZStack {
            Color.systemColor
                .ignoresSafeArea(.all)
            VStack(spacing: 20) {
                // AniList Icon
                Image("anilist") // Add AniList icon to Assets with this name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                    .accessibility(label: Text("AniList Icon"))
                
                // Not Logged In Text
                Text("You're Not Logged In")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary) // Adapts to light/dark mode
                
                Text("Please log in to your AniList account to view your Watch Lists")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
            }
            .padding(.horizontal, 20)
            
        }
    }
}


#Preview {
    NotLoggedInView()
}
