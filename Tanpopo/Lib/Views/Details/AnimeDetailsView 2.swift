import SwiftUI

// MARK: - Anime Details View

struct AnimeDetailsView: View {
    var anime: Anime

    var body: some View {
        ZStack(alignment: .top) {
            // Parallax Background Image
            ParallaxBackground(anime: anime)

            // Content Overlay
            ScrollView {
                VStack(spacing: 20) {
                    // Add spacing to push content below the background image
                    Spacer().frame(height: 250)

                    // Anime Title
                    Text(anime.titleRomaji)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.horizontal)

                    // Average Score and Episodes
                    HStack(spacing: 40) {
                        ScoreView(title: "Score", value: "\(anime.averageScore ?? 0)%", color: .yellow)
                        ScoreView(title: "Episodes", value: "\(anime.totalEpisodes ?? 0)", color: .orange)
                    }
                    .padding(.horizontal)

                    // Genre Tags
                    if let genres = anime.genres {
                        GenreTagsView(genres: genres)
                            .padding(.horizontal)
                    }

                    // Tags
                    if let tags = anime.tags {
                        TagsView(tags: tags)
                            .padding(.horizontal)
                    }

                    // Additional Info
                    HStack(spacing: 20) {
                        if let status = anime.status {
                            InfoView(title: "Status", value: status)
                        }
                        if let season = anime.season, let seasonYear = anime.seasonYear {
                            InfoView(title: "Season", value: "\(season.capitalized) \(seasonYear)")
                        }
                        if let format = anime.format {
                            InfoView(title: "Format", value: format)
                        }
                    }
                    .padding(.horizontal)

                    // Description
                    Text(
                        anime.description?
                            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                            ?? "No description available."
                    )
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()

                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.black)
    }
}

// MARK: - Parallax Background

struct ParallaxBackground: View {
    var anime: Anime

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: anime.bannerImage ?? anime.coverImageLarge)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Score View

struct ScoreView: View {
    var title: String
    var value: String
    var color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Genre Tags View

struct GenreTagsView: View {
    var genres: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                        .font(.caption)
                        .padding(5)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Tags View

struct TagsView: View {
    var tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(5)
                        .background(Color.green.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Info View

struct InfoView: View {
    var title: String
    var value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

struct AnimeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAnime = Anime(
            id: 171018,
            titleRomaji: "Dan Da Dan",
            coverImageLarge: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-2ldCj6QywuOa.jpg",
            totalEpisodes: 12,
            episodeProgress: 24,
            description: "This is a mock description of the anime. It provides an overview of the storyline and main themes.",
            bannerImage: nil,
            genres: ["Action", "Sci-Fi"],
            averageScore: 85,
            status: "FINISHED",
            season: "SUMMER",
            seasonYear: 2024,
            duration: 24,
            format: "TV",
            trailerID: nil,
            trailerSite: nil,
            tags: ["Sci-Fi", "Shounen"]
        )

        AnimeDetailsView(anime: mockAnime)
    }
}