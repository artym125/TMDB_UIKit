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
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
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
        lottieView = LottieAnimationView(name: "Animation_3")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()

        let lottieContainer = UIView()
        lottieContainer.addSubview(lottieView)
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: lottieContainer.centerXAnchor, constant: 37),
            lottieView.centerYAnchor.constraint(equalTo: lottieContainer.centerYAnchor, constant: 10),
            lottieView.widthAnchor.constraint(equalToConstant: 100),
            lottieView.heightAnchor.constraint(equalToConstant: 100)
        ])

        refreshControl.addSubview(lottieContainer)
        lottieContainer.frame = refreshControl.bounds
        refreshControl.tintColor = .clear
        tableView.refreshControl = refreshControl
    }
}
