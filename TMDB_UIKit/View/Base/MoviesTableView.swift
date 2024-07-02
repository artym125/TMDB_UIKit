//
//  MoviesTableView.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit
import Lottie

class MoviesTableView: UIView {
    
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    var lottieView: LottieAnimationView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
        setupRefreshControl()
    }

    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.value)
    }

    private func setupTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: R.Strings.movieTableViewCellTitle.value)
        addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupRefreshControl() {
        lottieView = LottieAnimationView(name: Constants.lottieAnimation)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()

        let lottieContainer = UIView()
        lottieContainer.addSubview(lottieView)
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: lottieContainer.centerXAnchor, constant: Constants.lottieViewCenterX),
            lottieView.centerYAnchor.constraint(equalTo: lottieContainer.centerYAnchor, constant: Constants.lottieViewCenterY),
            lottieView.widthAnchor.constraint(equalToConstant: Constants.lottieViewSize),
            lottieView.heightAnchor.constraint(equalToConstant: Constants.lottieViewSize)
        ])

        refreshControl.addSubview(lottieContainer)
        lottieContainer.frame = refreshControl.bounds
        refreshControl.tintColor = .clear
        tableView.refreshControl = refreshControl
    }
}

extension MoviesTableView {
    
    // MARK: - Constants
    
    enum Constants {
        static let lottieAnimation: String = "Animation_3"
        static let lottieViewCenterX: CGFloat = 37
        static let lottieViewCenterY: CGFloat = 10
        static let lottieViewSize: CGFloat = 100

    }
    
}
