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
    private let playTrailerButton = LottieAnimationView(name: Constants.animationName)
    
    init(movie: Movie) {
            self.movie = movie
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.value)
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
        posterImageView.layer.cornerRadius = Constants.cornerRadius
        view.addSubview(posterImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPosterFullscreen))
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(tapGesture)

        titleLabel.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        titleLabel.numberOfLines = Constants.titleNumberOfLines
        view.addSubview(titleLabel)

        countryLabel.font = UIFont.systemFont(ofSize: Constants.defaultFontSize)
        view.addSubview(countryLabel)

        descriptionLabel.font = UIFont.systemFont(ofSize: Constants.defaultFontSize)
        descriptionLabel.numberOfLines = Constants.defaultNumberOfLines
        view.addSubview(descriptionLabel)

        genreLabel.font = UIFont.systemFont(ofSize: Constants.defaultFontSize)
        genreLabel.numberOfLines = Constants.defaultNumberOfLines
        view.addSubview(genreLabel)

        ratingLabel.font = UIFont.boldSystemFont(ofSize: Constants.defaultFontSize)
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
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            posterImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            posterImageView.heightAnchor.constraint(equalToConstant: Constants.posterHeight),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            countryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallPadding),
            countryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            countryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            genreLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: Constants.smallPadding),
            genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            playTrailerButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: Constants.smallPadding),
            playTrailerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.zero),
            playTrailerButton.widthAnchor.constraint(equalToConstant: Constants.playButtonSize),
            playTrailerButton.heightAnchor.constraint(equalToConstant: Constants.playButtonSize),

            ratingLabel.centerYAnchor.constraint(equalTo: playTrailerButton.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            descriptionLabel.topAnchor.constraint(equalTo: playTrailerButton.bottomAnchor, constant: Constants.zero),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding)
        ])
    }

    @objc private func openPosterFullscreen() {
        guard let movie = movie, let posterImage = posterImageView.image else { return }
        let fullscreenVC = FullscreenPosterViewController(image: posterImage)
        present(fullscreenVC, animated: true, completion: nil)
    }

    private func configureUI() {
        guard let movie = movie else { return }

        if let posterPath = movie.posterPath, let url = URL(string: "\(Constants.imageBaseUrl)\(posterPath)") {
            posterImageView.kf.setImage(with: url)
        }

        titleLabel.text = movie.title
        descriptionLabel.text = movie.overview
        ratingLabel.text = "\(R.Strings.ratingTitle.value) \(String(format: "%.1f", movie.voteAverage))"
        genreLabel.text = movie.genreIDs.compactMap { MovieGenre(rawValue: $0)?.name }.joined(separator: ", ")

        if let movieCountry = MovieLanguage.from(code: movie.country) {
            countryLabel.text = "\(movieCountry.name), \(movie.releaseDate.prefix(Constants.movieReleaseDatePrefix))"
        } else {
            countryLabel.text = "\(movie.country), \(movie.releaseDate.prefix(Constants.movieReleaseDatePrefix))"
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
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(Constants.overlayAlpha)
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
        webView?.layer.cornerRadius = Constants.webViewCornerRadius
        view.addSubview(webView!)

        webView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            webView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            webView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            webView!.heightAnchor.constraint(equalToConstant: Constants.webViewHeight)
        ])

        webView?.isHidden = false
        overlayView?.isHidden = false
        let request = URLRequest(url: URL(string: embedURL)!)
        webView?.load(request)

        navigationController?.navigationBar.tintColor = UIColor.systemBlue.withAlphaComponent(Constants.tintAlpha)
    }

    @objc private func handleTapOverlay() {
        webView?.removeFromSuperview()
        overlayView?.isHidden = true
        navigationController?.navigationBar.tintColor = .systemBlue
    }
}

extension MovieDetailViewController {
    
    // MARK: - Constants
    
    enum Constants {
        static let zero: CGFloat = 0
        static let one: CGFloat = 1
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 15
        static let titleFontSize: CGFloat = 24
        static let movieReleaseDatePrefix: Int = 4
        static let defaultFontSize: CGFloat = 16
        static let titleNumberOfLines: Int = 0
        static let defaultNumberOfLines: Int = 0
        static let posterHeight: CGFloat = 200
        static let playButtonSize: CGFloat = 100
        static let overlayAlpha: CGFloat = 0.7
        static let webViewHeight: CGFloat = 400
        static let webViewCornerRadius: CGFloat = 20
        static let tintAlpha: CGFloat = 0.5
        static let animationName: String = "Youtube_B_Animation"
        static let imageBaseUrl: String = "https://image.tmdb.org/t/p/w500"
    }
}

