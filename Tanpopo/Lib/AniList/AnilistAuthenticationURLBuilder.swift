//
//  AnilistAuthenticationURLBuilder.swift
//  Tanpopo
//
//  Created by Arthur Ditte on 06.10.24.
//


import Foundation


// MARK: - AnilistAuthenticationURLBuilder

class AnilistAuthenticationURLBuilder {
    let domain = "anilist.co"
    let clientID: Int

    init(clientID: Int) {
        self.clientID = clientID
    }

    func callAsFunction() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = "/api/v2/oauth/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: String(clientID)),
            URLQueryItem(name: "response_type", value: "token")
        ]
        return components.url!
    }
}
