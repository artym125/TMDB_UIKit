//
//  FullscreenPosterViewController.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit

class FullscreenPosterViewController: UIViewController, UIScrollViewDelegate {
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }

    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        scrollView.delegate = self
        scrollView.minimumZoomScale = Constants.minimumZoomScale
        scrollView.maximumZoomScale = Constants.maximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle(R.Strings.close_button_title.value, for: .normal)
        closeButton.addTarget(self, action: #selector(closeFullscreen), for: .touchUpInside)
        closeButton.tintColor = .white
        view.addSubview(closeButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.buttonTopPadding),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.buttonTrailingPadding)
        ])
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @objc private func closeFullscreen() {
        dismiss(animated: true, completion: nil)
    }
}

extension FullscreenPosterViewController {
    
    // MARK: - Constants
    
    enum Constants {
        static let minimumZoomScale: CGFloat = 1.0
        static let maximumZoomScale: CGFloat = 5.0
        static let buttonTopPadding: CGFloat = 16
        static let buttonTrailingPadding: CGFloat = -16
    }
}
