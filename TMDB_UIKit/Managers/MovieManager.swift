//
//  MovieManager.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation
import Alamofire

class MovieManager {
    
    private let apiKey = K.Strings.api_tmdb.value
    private var isFetching = false
    
    func fetchPopularMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&page=\(page)"
        fetchMovies(urlString: urlString, completion: completion)
    }
    
    func fetchMoviesByGenre(genreID: Int, page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&with_genres=\(genreID)&page=\(page)"
        fetchMovies(urlString: urlString, completion: completion)
    }
    
    private func fetchMovies(urlString: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MovieManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url).validate().responseDecodable(of: MovieResponse.self) { response in
            switch response.result {
            case .success(let movieResponse):
                completion(.success(movieResponse.results))
            case .failure(let error):
                completion(.failure(error))
            }
            self.isFetching = false
        }
    }
}
