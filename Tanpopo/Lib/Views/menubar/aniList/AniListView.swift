//
//  AniListView.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 10.11.24.
//

import SwiftUI

struct AniListView: View {
    @StateObject var User = AniListAuthManager.shared
    @State private var animeList = [Anime]()
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        ZStack {
            NavigationStack {
                List(animeList) { anime in
                    NavigationLink(destination: AnimeDetailsView(anime: anime)) {
                        HStack {
                            AsyncImage(url: URL(string: anime.coverImageLarge)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 75)
                            .cornerRadius(8)

                            VStack(alignment: .leading) {
                                Text(anime.titleRomaji)
                                    .font(.headline)
                                Text("Episodes: \(anime.episodeProgress)/\(anime.totalEpisodes ?? 00)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("AniList")
                .padding(.top, 0)
            }
            
            // Empty List
            if animeList.isEmpty {
                EmptyWatchListView()
            }
            
            // No User
            if !User.isAuthenticated {
                NotLoggedInView()
            }
        }
        .onAppear {
            if let userId = userSession.user?.id,
               let accessToken = getUserIdFromKeychain() {
                fetchAnimeData(accessToken: accessToken, userId: userId) { fetchedAnimeList in
                    self.animeList = fetchedAnimeList
                }
            } else {
                //self.animeList = Anime.placeholderAnimeList
                self.animeList = []
            }
        }
    }
}


#Preview {
    AniListView()
}
