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
        case api_tmdb = "1111"
        
        //MARK: - YOUTUBE API -
        case api_youtube = "0000"
        case youtube_url = "https://www.googleapis.com/youtube/v3"
        
        var value: String {
            return rawValue
        }
    
    }
}
