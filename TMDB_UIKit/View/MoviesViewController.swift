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
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadMovies()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupNavBarMenu()
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
    
    private func setupTableView() {
        moviesTableView.tableView.delegate = self
        moviesTableView.tableView.dataSource = self
        view.addSubview(moviesTableView)
        
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moviesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
                image: genre == selectedGenre ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"),
                handler: { [weak self] _ in
                    self?.selectedGenre = genre
                    self?.title = genre.name
                    self?.viewModel.loadMovies(genreID: genre)
                    self?.navigationItem.rightBarButtonItem?.menu = self?.createMenu()
                }
            )
        }
        
        let recommendedAction = UIAction(
            title: "Popular Movies",
            image: selectedGenre == nil ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"),
            handler: { [weak self] _ in
                self?.selectedGenre = nil
                self?.title = "Popular Movies"
                self?.viewModel.loadMovies()
                self?.navigationItem.rightBarButtonItem?.menu = self?.createMenu()
            }
        )
        
        actions.insert(recommendedAction, at: 0)
        return UIMenu(children: actions)
    }
    
    @objc private func refreshMovies() {
        guard networkMonitor.isActive else {
            showOfflineAlert()
            moviesTableView.refreshControl.endRefreshing()
            return
        }
        
        viewModel.loadMovies(genreID: selectedGenre)
    }
    
    private func setupNavBarMenu() {
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.and.down.text.horizontal"), menu: createMenu())
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func showOfflineAlert() {
        let alert = UIAlertController(title: "Offline Mode", message: "You are currently offline. Please check your network connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = viewModel.filteredMovies[indexPath.row]
        cell.configure(with: movie)
        
        if indexPath.row == viewModel.filteredMovies.count - 1 {
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
        if position > tableView.contentSize.height - 100 - scrollView.frame.size.height {
            viewModel.loadMoreMoviesIfNeeded()
        }
    }
}

import UIKit

class MovieDetailViewController: UIViewController {
    
    private let movie: Movie
    
    // UI Elements
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    
    // Initializer
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movie Details"
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.numberOfLines = 0
        
        view.addSubview(posterImageView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 200),
            posterImageView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func configureUI() {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        // Assuming you have a method to fetch image from a URL
        if let posterPath = movie.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w500" + posterPath
            if let url = URL(string: urlString) {
                fetchImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
                    }
                }
            }
        }
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // UI Elements
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        overviewLabel.font = .systemFont(ofSize: 14)
        overviewLabel.textColor = .gray
        overviewLabel.numberOfLines = 3
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            overviewLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        
        if let posterPath = movie.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w200" + posterPath
            if let url = URL(string: urlString) {
                fetchImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
                    }
                }
            }
        }
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

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
