//
//  EmptyWatchListView.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 15.11.24.
//

import SwiftUI

struct EmptyWatchListView: View {
    var body: some View {
        ZStack {
            Color.systemColor
                .ignoresSafeArea(.all)
            VStack(spacing: 20) {
                // Illustration or Icon
                Image(systemName: "tv")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.6))
                
                // Title Text
                Text("Your Watching List is Empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Description or Suggestion
                Text("Start adding anime to your watching list to keep track of your progress!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                // Call to Action Button
                Button(action: {
                    // Navigate to anime search or discovery
                    print("Navigate to anime discovery")
                }) {
                    Text("Discover Anime")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 50)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
}


#Preview {
    EmptyWatchListView()
}
