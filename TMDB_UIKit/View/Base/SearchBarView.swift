//
//  SearchBarView.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit

class SearchBarView: UIView {
    let searchBar = UISearchBar()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar()
    }

    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.rawValue)
    }

    private func setupSearchBar() {
        searchBar.placeholder = R.Strings.searchTitle.value
        searchBar.sizeToFit()
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
