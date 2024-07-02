//
//  MovieDetailViewController.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit
import WebKit
import Lottie
import Kingfisher

class MovieDetailViewController: UIViewController {
    
    var movie: Movie?
    private var webView: WKWebView?
    private var overlayView: UIView?
    private var trailerURL: String?

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let genreLabel = UILabel()
    private let ratingLabel = UILabel()
    private let countryLabel = UILabel()
    private let playTrailerButton = LottieAnimationView(name: "Youtube_B_Animation")
    
    init(movie: Movie) {
            self.movie = movie
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = movie?.title

        setupUI()
        configureUI()
    }

    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 15
        view.addSubview(posterImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPosterFullscreen))
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(tapGesture)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)

        countryLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(countryLabel)

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)

        genreLabel.font = UIFont.systemFont(ofSize: 16)
        genreLabel.numberOfLines = 0
        view.addSubview(genreLabel)

        ratingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(ratingLabel)

        playTrailerButton.contentMode = .scaleAspectFit
        playTrailerButton.loopMode = .loop
        let playTrailerGesture = UITapGestureRecognizer(target: self, action: #selector(playTrailer))
        playTrailerButton.addGestureRecognizer(playTrailerGesture)
        playTrailerButton.isUserInteractionEnabled = true
        view.addSubview(playTrailerButton)

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        playTrailerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            posterImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            countryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            genreLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            playTrailerButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 8),
            playTrailerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            playTrailerButton.widthAnchor.constraint(equalToConstant: 100),
            playTrailerButton.heightAnchor.constraint(equalToConstant: 100),

            ratingLabel.centerYAnchor.constraint(equalTo: playTrailerButton.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: playTrailerButton.bottomAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func openPosterFullscreen() {

    }

    private func configureUI() {
        guard let movie = movie else { return }

        if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            posterImageView.kf.setImage(with: url)
        }

        titleLabel.text = movie.title
        descriptionLabel.text = movie.overview
        ratingLabel.text = "Rating: \(String(format: "%.1f", movie.voteAverage))"
        genreLabel.text = movie.genreIDs.compactMap { MovieGenre(rawValue: $0)?.name }.joined(separator: ", ")

        if let movieCountry = MovieLanguage.from(code: movie.country) {
            countryLabel.text = "\(movieCountry.name), \(movie.releaseDate.prefix(4))"
        } else {
            countryLabel.text = "\(movie.country), \(movie.releaseDate.prefix(4))"
        }

        let youTubeService = YouTubeManager()
        youTubeService.fetchTrailer(for: movie.title) { [weak self] embedURL in
            DispatchQueue.main.async {
                self?.trailerURL = embedURL
                self?.playTrailerButton.isHidden = (embedURL == nil)
                if embedURL != nil {
                    self?.playTrailerButton.play()
                } else {
                    self?.playTrailerButton.stop()
                }
            }
        }
    }

    @objc private func playTrailer() {
        guard let trailerURL = trailerURL else { return }

        showOverlay()
        loadWebView(with: trailerURL)
    }

    private func showOverlay() {
        overlayView = UIView()
        overlayView?.isHidden = true
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOverlay))
        overlayView?.addGestureRecognizer(tapGesture)
        view.addSubview(overlayView!)
        overlayView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView!.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadWebView(with embedURL: String) {
        webView = WKWebView()
        webView?.isHidden = true
        webView?.layer.cornerRadius = 20
        view.addSubview(webView!)

        webView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            webView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            webView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            webView!.heightAnchor.constraint(equalToConstant: 400)
        ])

        webView?.isHidden = false
        overlayView?.isHidden = false
        let request = URLRequest(url: URL(string: embedURL)!)
        webView?.load(request)

        navigationController?.navigationBar.tintColor = .systemBlue.withAlphaComponent(0.5)
    }

    @objc private func handleTapOverlay() {
        webView?.removeFromSuperview()
        overlayView?.isHidden = true
        navigationController?.navigationBar.tintColor = .systemBlue
    }
}
