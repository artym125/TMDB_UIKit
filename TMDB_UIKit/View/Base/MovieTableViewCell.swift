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
        let animationView = LottieAnimationView(name: "Loading_Animation_2")
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
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.addSubview(customImageView)
//        contentView.addSubview(activityIndicator)
        contentView.addSubview(loadingAnimationView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                        customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                        customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                        customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                        customImageView.heightAnchor.constraint(equalToConstant: 200),
                        
                        loadingAnimationView.centerXAnchor.constraint(equalTo: customImageView.centerXAnchor),
                        loadingAnimationView.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor),
                        loadingAnimationView.widthAnchor.constraint(equalToConstant: 200),
                        loadingAnimationView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupShadow() {
        customImageView.layer.shadowColor = UIColor.black.cgColor
        customImageView.layer.shadowOpacity = 0.9
        customImageView.layer.shadowOffset = CGSize(width: 1, height: 7)
        customImageView.layer.shadowRadius = 7
        customImageView.layer.masksToBounds = false
    }
    
    // MARK: - Configuration
    
    func configure(with movie: Movie) {
//        loadingAnimationView.isHidden = false
//                    loadingAnimationView.play()
        
        
        if let posterPath = movie.posterPath, let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            customImageView.imageView.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
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
                customImageView.imageView.image = UIImage(named: "NoImage")
            }
        }
        
        customImageView.topTextLabel.text = movie.title
        customImageView.randomTextLabel.text = String(movie.releaseDate.prefix(4))
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
        static let imageName = "image_1"
        static let imageViewHeight: CGFloat = 300
        static let imageCornerRadius: CGFloat = 20
        static let backgroundCornerRadius: CGFloat = 15
        static let labelFontSize: CGFloat = 16
        static let padding: CGFloat = 16
        static let textPadding: CGFloat = 16
        static let labelPadding: CGFloat = 8
    }
}

