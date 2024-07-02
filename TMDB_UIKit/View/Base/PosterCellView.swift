//
//  PosterCellView.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit

class PosterCellView: UIView {
    
    // MARK: - Properties`
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var topTextLabel: UILabel = createLabel(fontSize: Constants.MainTitleFontSize, weight: .bold, textColor: .white)

    lazy var randomTextLabel: UILabel = createLabel(fontSize: Constants.labelFontSize, weight: .bold, textColor: .white)

    lazy var bottomLeftTextLabel: UILabel = createLabel(fontSize: Constants.labelFontSize, weight: .bold, textColor: .white, alpha: Constants.subTextOpacity)

    lazy var bottomRightTextLabel: UILabel = createLabel(fontSize: Constants.labelFontSize, weight: .bold, textColor: .white, alpha: Constants.subTextOpacity)
    
    lazy var starImageView: UIImageView = {
        let starImage = UIImage(systemName: "star.fill")
        let imageView = UIImageView(image: starImage)
        imageView.tintColor = .yellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    
    init(image: UIImage, topText: String, randomText: String, bottomLeftText: String, bottomRightText: String) {
        super.init(frame: .zero)
        
        imageView.image = image
        topTextLabel.text = topText
        randomTextLabel.text = randomText
        bottomLeftTextLabel.text = bottomLeftText
        bottomRightTextLabel.text = bottomRightText
        
        setupImageView()
        setupTextLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    func setupImageView() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imagePadding),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imagePadding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.imagePadding),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight)
        ])
    }
    
    func createLabel(fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, alpha: CGFloat = 1.0) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor.withAlphaComponent(alpha)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setupTextLabels() {
        setupTextLabel(label: topTextLabel, at: .topLeft)
        setupTextLabel(label: randomTextLabel, at: .topRightBelowTopText)
        setupTextLabel(label: bottomLeftTextLabel, at: .bottomLeft)
        setupBottomRightLabelWithStar() // Оновлений метод для налаштування правого нижнього тексту та зірки
    }
    
    private func setupTextLabel(label: UILabel, at position: TextPosition) {
        let background = makeBackgroundView()
        addSubview(background)
        
        switch position {
        case .topLeft:
            NSLayoutConstraint.activate([
                background.topAnchor.constraint(equalTo: imageView.topAnchor, constant: Constants.topBackPadding),
                background.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: Constants.textPadding),
                background.trailingAnchor.constraint(lessThanOrEqualTo: imageView.trailingAnchor, constant: -Constants.textPadding)
            ])
        case .topRightBelowTopText:
            NSLayoutConstraint.activate([
                background.topAnchor.constraint(equalTo: topTextLabel.bottomAnchor, constant: Constants.preTopBackPadding),
                background.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: Constants.textPadding)
            ])
        case .bottomLeft:
            NSLayoutConstraint.activate([
                background.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.textPadding),
                background.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: Constants.textPadding),
//                background.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 200)
                background.trailingAnchor.constraint(lessThanOrEqualTo: imageView.trailingAnchor,constant: -30)
                
            ])
        default:
            break
        }
        
        background.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: background.topAnchor, constant: Constants.labelPadding),
            label.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: Constants.labelPadding),
            label.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -Constants.labelPadding),
            label.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -Constants.labelPadding)
        ])
    }
    
    private func setupBottomRightLabelWithStar() {
        let background = makeBackgroundView()
        addSubview(background)

        background.addSubview(starImageView)
        background.addSubview(bottomRightTextLabel)
        
        NSLayoutConstraint.activate([
            background.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.textPadding),
            background.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -Constants.textPadding),

            starImageView.widthAnchor.constraint(equalToConstant: Constants.starSize),
            starImageView.heightAnchor.constraint(equalToConstant: Constants.starSize),
            starImageView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: Constants.labelPadding),
            starImageView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            
            bottomRightTextLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: Constants.labelPadding),
            bottomRightTextLabel.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -Constants.labelPadding),
            bottomRightTextLabel.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            
            background.topAnchor.constraint(equalTo: starImageView.topAnchor, constant: -Constants.labelPadding),
            background.bottomAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: Constants.labelPadding)
        ])
    }
    
    private func makeBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(Constants.subTextOpacity)
        view.layer.cornerRadius = Constants.backgroundCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension PosterCellView {
    
    // MARK: - Constants
    
    enum Constants {
        static let imageViewHeight: CGFloat = 200
        static let imageCornerRadius: CGFloat = 10
        static let imagePadding: CGFloat = 0
        static let backgroundCornerRadius: CGFloat = 6
        static let MainTitleFontSize: CGFloat = 20
        static let labelFontSize: CGFloat = 10
        static let padding: CGFloat = 16
        static let textPadding: CGFloat = 6
        static let labelPadding: CGFloat = 3
        static let subTextOpacity: CGFloat = 0.75
        static let topBackPadding: CGFloat = 4
        static let preTopBackPadding: CGFloat = 6
        static let starSize: CGFloat = 10
    }
    
    enum TextPosition {
        case topLeft, topRightBelowTopText, bottomLeft, bottomRight
    }
}
