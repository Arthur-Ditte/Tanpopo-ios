//
//  Anime.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//


import Foundation

struct Anime: Codable {
    let id: Int
    let title: Titles
    let coverImage: CoverImage?
    let description: String?
}

struct Titles: Codable {
    let romaji: String
    let english: String?
    let native: String?
}

struct CoverImage: Codable {
    let extraLarge: String?
}

struct MediaListCollectionResponse: Codable {
    struct DataClass: Codable {
        struct MediaListCollection: Codable {
            struct List: Codable {
                struct Entry: Codable {
                    let media: Anime
                }
                let entries: [Entry]
            }
            let lists: [List]
        }
        let MediaListCollection: MediaListCollection
    }
    let data: DataClass
}