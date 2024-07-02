//
//  R+Strings.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation

enum R {
    
    enum Strings: String {
        
        //MARK: - Movie VC -
        case movieVC_title = "Popular Movies"
        
        //ALERT
        
        case alert_offline_title = "Offline Mode"
        case alert_offline_message = "You are currently offline. Please check your network connection."
        case alert_offline_OK = "OK"
        
        case movieTableViewCellTitle = "MovieTableViewCell"
        case cancel_button_title = "Cancel"
        case close_button_title = "Close"
        
        case fatalErrorMessage = "init(coder:) has not been implemented"
        case errorFetchMovies = "Error fetching movies:"
        case errorFetchMoreMovies = "Error fetching more movies:"
        
        case errorSearchingMovies = "Error searching movies:"
        
        //MARK: - MovieDetail VC -
        
        case ratingTitle = "Rating:"
        
        case searchTitle = "Search"
       
        
        //MARK: - YOUTUBE API -
        case api_youtube = "AIzaSyC2v6mwAnjiQ9xPFHcLzxMaqiKqU2Wv-4g"
        case youtube_url = "https://www.googleapis.com/youtube/v3"
        
        var value: String {
            return rawValue
        }
    
    }
}
