//
//  Movie.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String
    let genreIDs: [Int]
    let voteAverage: Double
    let country: String
    
    var posterURL: URL? {
        if let posterPath = posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, releaseDate = "release_date", genreIDs = "genre_ids", voteAverage = "vote_average", country = "original_language", posterPath = "poster_path"
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

