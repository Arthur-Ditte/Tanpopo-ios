//
//  AnilistAPIConfigurations.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//

import Foundation


// MARK: - AnilistAPIConfigurations

struct AnilistAPIConfigurations {
    static func load() -> (id: Int, redirectURL: String) {
        guard let url = Bundle.main.url(forResource: "AnilistAPIConfigurations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: Any],
              let id = dictionary["id"] as? Int,
              let redirectURL = dictionary["redirectURL"] as? String else {
            fatalError("Failed to load Anilist API configurations.")
        }
        
        return (id, redirectURL)
    }
}
