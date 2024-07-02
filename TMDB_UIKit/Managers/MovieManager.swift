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
        
        let urlString = "\(Constants.baseURL)/movie/popular?api_key=\(apiKey)&page=\(page)"
        fetchMovies(urlString: urlString, completion: completion)
    }
    
    func fetchMoviesByGenre(genreID: Int, page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        
        let urlString = "\(Constants.baseURL)/discover/movie?api_key=\(apiKey)&with_genres=\(genreID)&page=\(page)"
        fetchMovies(urlString: urlString, completion: completion)
    }
    
    private func fetchMovies(urlString: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: Constants.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: Constants.invalidURLError])))
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

extension MovieManager {
    
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(Constants.baseURL)/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        fetchMovies(urlString: urlString, completion: completion)
    }
}

extension MovieManager {
    
    // MARK: - Constants
    
    enum Constants {
        static let baseURL = "https://api.themoviedb.org/3"
        static let errorDomain = "MovieManager"
        static let invalidURLError = "Invalid URL"
    }
}
