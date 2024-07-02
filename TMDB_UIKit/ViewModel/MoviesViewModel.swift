//
//  MoviesViewModel.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation

class MoviesViewModel {
    private let movieService = MovieManager()
    private var currentPage = 1
    private var totalLoadedMovies = 0
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    var onUpdate: (() -> Void)?
    var currentGenreID: MovieGenre?
    
    /// Завантажує фільми з сервера, фільтруючи за жанром, якщо вказаний.
    /// - Parameter genreID: Опціональний параметр, що визначає ID жанру для фільтрації фільмів. Якщо `genreID` не вказаний, завантажуються популярні фільми.
    func loadMovies(genreID: MovieGenre? = nil) {
        currentPage = 1
        totalLoadedMovies = 0
        currentGenreID = genreID
        
        if let genreID = genreID {
            movieService.fetchMoviesByGenre(genreID: genreID.rawValue, page: currentPage) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.filteredMovies = movies
                    self?.totalLoadedMovies += movies.count
                    self?.onUpdate?()
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }
        } else {
            movieService.fetchPopularMovies(page: currentPage) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.filteredMovies = movies
                    self?.totalLoadedMovies += movies.count
                    self?.onUpdate?()
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Завантажує більше фільмів, якщо це необхідно.
    /// Тобто 1 сторінка має 20 фільмів, тому кожного разу додаємо сторінку +=1 та завантажуєемо наступний 20 фільмів
    /// Функція перевіряє, чи досягнуто поточного ліміту завантажених фільмів, і якщо так, завантажує наступну сторінку даних.
    /// Якщо є поточний вибраний жанр, завантажуються фільми відповідного жанру, інакше - популярні фільми.
    func loadMoreMoviesIfNeeded() {
        if totalLoadedMovies == 20 {
            currentPage += 1
            totalLoadedMovies = 0
        }
        
        if let genreID = currentGenreID {
            movieService.fetchMoviesByGenre(genreID: genreID.rawValue, page: currentPage) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies.append(contentsOf: movies)
                    self?.filteredMovies = self?.movies ?? []
                    self?.totalLoadedMovies += movies.count
                    self?.onUpdate?()
                case .failure(let error):
                    print("Error fetching more movies: \(error.localizedDescription)")
                }
            }
        } else {
            movieService.fetchPopularMovies(page: currentPage) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.movies.append(contentsOf: movies)
                    self?.filteredMovies = self?.movies ?? []
                    self?.totalLoadedMovies += movies.count
                    self?.onUpdate?()
                case .failure(let error):
                    print("Error fetching more movies: \(error.localizedDescription)")
                }
            }
        }
    }
}
