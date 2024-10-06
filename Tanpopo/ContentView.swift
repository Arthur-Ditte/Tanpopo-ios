//
//  ContentView.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 05.10.24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("AniList", systemImage: "play.circle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            MediaView()
                .tabItem {
                    Label("Media", systemImage: "film")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


