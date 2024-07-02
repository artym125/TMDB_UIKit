//
//  MovieTableViewCell.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit
import Lottie
import Kingfisher

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    lazy var customImageView: PosterCellView = {
        let view = PosterCellView(
            image: UIImage(),
            topText: "",
            randomText: "",
            bottomLeftText: "",
            bottomRightText: ""
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: Constants.loadingAnimationName)
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
        setupShadow()
        
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.value)
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.addSubview(customImageView)
        contentView.addSubview(loadingAnimationView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            customImageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),
                        
            loadingAnimationView.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalToConstant: Constants.animationSize),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: Constants.animationSize)
        ])
    }
    
    private func setupShadow() {
        customImageView.layer.shadowColor = UIColor.black.cgColor
        customImageView.layer.shadowOpacity = Constants.shadowOpacity
        customImageView.layer.shadowOffset = Constants.shadowOffset
        customImageView.layer.shadowRadius = Constants.shadowRadius
        customImageView.layer.masksToBounds = false
    }
    
    // MARK: - Configuration
    
    func configure(with movie: Movie) {

        if let posterPath = movie.posterPath, let imageUrl = URL(string: "\(Constants.imageBaseUrl)\(posterPath)") {
            customImageView.imageView.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [.transition(.fade(Constants.imageFadeDuration)), .cacheOriginalImage]
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.loadingAnimationView.stop()
                    self?.loadingAnimationView.isHidden = true
                case .failure:
                    if !NetworkMonitor.shared.isActive {
                        self?.loadingAnimationView.isHidden = false
                        self?.loadingAnimationView.play()
                    }
                }
            }
        } else {
            customImageView.imageView.image = nil
            if !NetworkMonitor.shared.isActive {
                loadingAnimationView.isHidden = false
                loadingAnimationView.play()
            } else {
                loadingAnimationView.stop()
                loadingAnimationView.isHidden = true
                customImageView.imageView.image = UIImage(named: Constants.noImageName)
            }
        }
        
        customImageView.topTextLabel.text = movie.title
        customImageView.randomTextLabel.text = String(movie.releaseDate.prefix(Constants.releaseDatePrefixLength))
        customImageView.bottomLeftTextLabel.text = movie.genreIDs.compactMap { MovieGenre(rawValue: $0)?.name }.joined(separator: ", ")
        customImageView.bottomRightTextLabel.text = String(format: "%.1f", movie.voteAverage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.imageView.image = nil
        loadingAnimationView.stop()
        loadingAnimationView.isHidden = true
    }
}

extension MovieTableViewCell {
    
    // MARK: - Constants
    
    enum Constants {
        static let padding: CGFloat = 10
        static let imageViewHeight: CGFloat = 200
        static let animationSize: CGFloat = 200
        static let shadowOpacity: Float = 0.9
        static let shadowOffset = CGSize(width: 1, height: 7)
        static let shadowRadius: CGFloat = 7
        static let loadingAnimationName = "Loading_Animation_2"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/w500"
        static let imageFadeDuration: TimeInterval = 0.2
        static let noImageName = "NoImage"
        static let releaseDatePrefixLength = 4
    }
}
