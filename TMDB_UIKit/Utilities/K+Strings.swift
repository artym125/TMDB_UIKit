//
//  K+String.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation

enum K {
    
    enum Strings: String {
        
        //MARK: - TMDB API -
        case api_tmdb = "bb9c069111acd5473e4758216e2ce841"
        
        //MARK: - YOUTUBE API -
        case api_youtube = "AIzaSyC2v6mwAnjiQ9xPFHcLzxMaqiKqU2Wv-4g"
        case youtube_url = "https://www.googleapis.com/youtube/v3"
        
        var value: String {
            return rawValue
        }
    
    }
}
