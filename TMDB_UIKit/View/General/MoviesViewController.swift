//
//  MoviesViewController.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import UIKit
import Network
import Lottie

class MoviesViewController: UIViewController {
    
    private let viewModel: MoviesViewModel
    private let networkMonitor: NetworkMonitor
    private let searchBarView = SearchBarView()
    private let moviesTableView = MoviesTableView()
    private var selectedGenre: MovieGenre?
    
    private var isOnline: Bool = true {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = isOnline
        }
    }
    
    // Dependency Injection through initializer
    init(viewModel: MoviesViewModel = MoviesViewModel(), networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.viewModel = viewModel
        self.networkMonitor = networkMonitor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(R.Strings.fatalErrorMessage.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadMovies()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = R.Strings.movieVC_title.value
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupNavBarMenu()
        setupSearchBar()
        setupTableView()
        setupNetworkMonitor()
        setupTapGesture()
    }
    
    private func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.moviesTableView.tableView.reloadData()
                self?.moviesTableView.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupSearchBar() {
        searchBarView.searchBar.delegate = self
        view.addSubview(searchBarView)
        
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        moviesTableView.tableView.delegate = self
        moviesTableView.tableView.dataSource = self
        view.addSubview(moviesTableView)
        
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moviesTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            moviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moviesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        moviesTableView.refreshControl.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkChange(path: path)
        }
    }
    
    private func handleNetworkChange(path: NWPath) {
        isOnline = path.status == .satisfied
        if !isOnline {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.showOfflineAlert()
            }
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Ensure the tap doesn't cancel other touch events
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func createMenu() -> UIMenu {
        var actions = MovieGenre.allCases.map { genre in
            UIAction(
                title: genre.name,
                image: genre == selectedGenre ? .checkmarkCircleFill : .checkmarkCircle,
                handler: { [weak self] _ in
                    self?.selectedGenre = genre
                    self?.title = genre.name
                    self?.viewModel.loadMovies(genreID: genre)
                    self?.navigationItem.rightBarButtonItem?.menu = self?.createMenu()
                }
            )
        }
        
        let recommendedAction = UIAction(
            title: R.Strings.movieVC_title.value,
            image: selectedGenre == nil ? .checkmarkCircleFill : .checkmarkCircle,
            handler: { [weak self] _ in
                self?.selectedGenre = nil
                self?.title = R.Strings.movieVC_title.value
                self?.viewModel.loadMovies()
                self?.navigationItem.rightBarButtonItem?.menu = self?.createMenu()
            }
        )
        
        actions.insert(recommendedAction, at: Constants.zero)
        return UIMenu(children: actions)
    }
    
    @objc private func refreshMovies() {
        guard let query = searchBarView.searchBar.text, query.isEmpty else {
            moviesTableView.refreshControl.endRefreshing()
            return
        }
        
        guard networkMonitor.isActive else {
            showOfflineAlert()
            moviesTableView.refreshControl.endRefreshing()
            return
        }
        
        viewModel.loadMovies(genreID: selectedGenre)
    }
    
    private func setupNavBarMenu() {
        let menuButton = UIBarButtonItem(image: .sortingMenuImage, menu: createMenu())
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func showOfflineAlert() {
        let alert = UIAlertController(title: R.Strings.alert_offline_title.value, message: R.Strings.alert_offline_message.value, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.Strings.alert_offline_OK.value, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Strings.movieTableViewCellTitle.value, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = viewModel.filteredMovies[indexPath.row]
        cell.configure(with: movie)
        
        if indexPath.row == viewModel.filteredMovies.count - Constants.one {
            viewModel.loadMoreMoviesIfNeeded()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = viewModel.filteredMovies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: movie)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - Constants.didScrollingPosition - scrollView.frame.size.height {
            viewModel.loadMoreMoviesIfNeeded()
        }
    }

}

// MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        title = searchText.isEmpty ? R.Strings.movieVC_title.value : searchText
        updateCancelButtonVisibility()
        if searchText.isEmpty {
            viewModel.loadMovies(genreID: selectedGenre)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateCancelButtonVisibility()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == true {
            setupNavBarMenu()
            viewModel.loadMovies(genreID: selectedGenre)
            disableNavBarMenu()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard networkMonitor.isActive else {
            showOfflineAlert()
            return
        }
        
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.searchMovies(query: query)
        searchBar.resignFirstResponder()
    }
    
    @objc private func cancelSearch() {
        searchBarView.searchBar.text = nil
        searchBarView.searchBar.resignFirstResponder()
        viewModel.loadMovies(genreID: selectedGenre)
        title = R.Strings.movieVC_title.value
        setupNavBarMenu()
        disableNavBarMenu()
    }
    
    private func updateCancelButtonVisibility() {
        if let searchText = searchBarView.searchBar.text, !searchText.isEmpty {
            let cancelButton = UIBarButtonItem(title: R.Strings.cancel_button_title.value, style: .plain, target: self, action: #selector(cancelSearch))
            cancelButton.tintColor = .red
            navigationItem.rightBarButtonItem = cancelButton
        } else {
            setupNavBarMenu()
            disableNavBarMenu()
        }
    }
    
    private func disableNavBarMenu() {
        if !networkMonitor.isActive {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

extension MoviesViewController {
    
    // MARK: - Constants
    
    enum Constants {
        static let zero: Int = 0
        static let one: Int = 1
        static let didScrollingPosition: CGFloat = 100
    }
}
