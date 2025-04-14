//
//  ViewController.swift
//  GimPlay
//
//  Created by Wildan on 06/03/25.
//

import UIKit
import RxSwift
import Genre
import Game
import Core

class ViewController: UIViewController {

    @IBOutlet weak var genreIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var gameTableIndicator: UIActivityIndicatorView!
    @IBOutlet weak var genresCollectionView: UICollectionView!
    @IBOutlet weak var categoriesTitle: UILabel!
    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var filterList: UIStackView!
    private var filterButtons: [UIButton] = []

    private var searchBarQuery: String?
    private var selectedFilter: Int = 0

    private var games: [GameModel] = []
    private var genres: [GenreModel] = []
    private var error: String?

//    var presenter: HomePresenter?
    var gamePresenter: GamePresenter<GameInteractor>?
    var genrePresenter: GenresPresenter<GenreInteractor>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        createSearchBar()

        filterList.spacing = 4
        filterList.distribution = .fillEqually
        for idx in GameFilterList.allCases.indices {
            let filterBtn = UIButton(type: .system)
            filterBtn.setTitle(GameFilterList.fromIndex(idx), for: .normal)
            filterBtn.setTitleColor(.white, for: .normal)
            filterBtn.backgroundColor = (idx == selectedFilter) ? .systemMint : .systemBlue
            filterBtn.layer.cornerRadius = 10
            filterBtn.layer.masksToBounds = true
            filterBtn.heightAnchor.constraint(equalToConstant: 80).isActive = true
            filterBtn.tag = idx

            filterBtn.addTarget(self, action: #selector(filterBtnTapped(_:)), for: .touchUpInside)

            filterList.addArrangedSubview(filterBtn)
            filterButtons.append(filterBtn)
        }

        gamesTableView.dataSource = self
        gamesTableView.register(
            UINib(nibName: "GameCardViewCell", bundle: nil),
            forCellReuseIdentifier: "gameCardViewCell"
        )
        gamesTableView.delegate = self

        genresCollectionView.dataSource = self
        genresCollectionView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorText.isHidden = true
        gameTableIndicator.startAnimating()
        genreIndicator.startAnimating()

        bindPresenter()

        if games.isEmpty {
            getGames(GameFilterList.fromIndex(selectedFilter))
        } else {
            self.gameTableIndicator.stopAnimating()
            self.gameTableIndicator.isHidden = true
        }

        if genres.isEmpty {
            getGenres()
        } else {
            self.genreIndicator.stopAnimating()
            self.genreIndicator.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "moveToDetail":
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.gameData = sender as? (Int, String)
            }
        case "moveToGenre":
            if let genreViewController = segue.destination as? GenreViewController {
                genreViewController.genreData = sender as? (Int, String)
                genreViewController.searchQueryData =
                sender as? String
            }
        default:
            print("Segue not founs")
        }
    }

    @IBAction func openSteamWebsite(_ sender: Any) {
        let shopUrl = "https://store.steampowered.com"

        if let url = URL(string: shopUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    @objc fileprivate func filterBtnTapped(_ sender: UIButton) {
        let filterValue = GameFilterList.fromIndex(sender.tag)

        for btn in filterButtons {
            btn.backgroundColor = .systemBlue
        }

        selectedFilter = sender.tag
        sender.backgroundColor = .systemMint

        games = []
        gamesTableView.reloadData()
        gameTableIndicator.isHidden = false
        gameTableIndicator.startAnimating()

        getGames(filterValue)
    }

    func createSearchBar() {
        let searchBar = UISearchBar()

        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search some fun games..."
        searchBar.delegate = self

        self.navigationItem.titleView = searchBar
    }

    func getGames(_ query: String) {
        gamePresenter?.execute(request: GamePresenterRequest.fetchGames(query, nil, nil))
    }

    func getGenres() {
        genrePresenter?.execute(request: GenrePresenterRequest.fetchGenresRemote)
    }

    func updateUIfromGetGames() {
        gameTableIndicator.stopAnimating()
        gameTableIndicator.isHidden = true

        gamesTableView.reloadData()
    }

    func updateUIfromGetGenres() {
        genreIndicator.stopAnimating()
        genreIndicator.isHidden = true

        genresCollectionView.reloadData()
    }

    func updateUIfromGettingError() {
        if let error = self.error {
            if games.isEmpty {
                gameTableIndicator.stopAnimating()
                gameTableIndicator.isHidden = true

                genreIndicator.stopAnimating()
                genreIndicator.isHidden = true

                errorText.text = error
                errorText.isHidden = false
            }

            self.view.showToast(message: error)
        }
    }

    private func bindPresenter() {
        gamePresenter?.games
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] games in
                self?.games.append(contentsOf: games)
                self?.updateUIfromGetGames()
            })
            .disposed(by: disposeBag)

        gamePresenter?.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.error = errorMessage
                self?.updateUIfromGettingError()
            })
            .disposed(by: disposeBag)

        genrePresenter?.genres
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] genres in
                self?.genres = genres
                self?.updateUIfromGetGenres()
            })
            .disposed(by: disposeBag)

        genrePresenter?.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.error = errorMessage
                self?.updateUIfromGettingError()
            })
            .disposed(by: disposeBag)
    }

    fileprivate func startDownloadImage(
        imageUrl: String?,
        downloadableImage: Core.DownloadableImage,
        indexPath: IndexPath,
        viewType: ViewType
    ) {
        let imageDownloader = ImageDownloader()

        if downloadableImage.state == .new {
            Task {
                do {
                    downloadableImage.state = .downloading

                    let image = try await imageDownloader.downloadImage(
                        from: URL(string: imageUrl ?? "https://placehold.co/600x400.png")!
                    )

                    downloadableImage.state = .done
                    downloadableImage.image = image

                    DispatchQueue.main.async {
                        switch viewType {
                        case .gameTable:
                            self.gamesTableView.reloadRows(at: [indexPath], with: .automatic)
                        case .genreCollection:
                            self.genresCollectionView.reloadItems(at: [indexPath])
                        }
                    }
                } catch {
                    downloadableImage.state = .failed
                    downloadableImage.image = UIImage(named: "placeholder")?.jpegData(compressionQuality: 1)
                }
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let offset = scrollView.contentOffset.y

        if offset > contentHeight - scrollViewHeight - 100 {
            if games.count > 0 {
                gamePresenter?.execute(request: GamePresenterRequest.fetchGames(GameFilterList.fromIndex(selectedFilter), nil, nil))
            }
        }
    }
}

// MARK: - Games Table View Data & UI Utils
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let gameCell = tableView.dequeueReusableCell(
            withIdentifier: "gameCardViewCell",
            for: indexPath
        ) as? GameCardViewCell {
            let game = games[indexPath.row]

            gameCell.gameGenresView.text = game.genres.map { $0.name }.joined(separator: ", ")
            gameCell.gameTitleView.text = game.name
            gameCell.gameRatingView.text = "\(game.rating)/\(game.ratingTop)★ - Metacritic: \(game.metacritic != nil ? String(game.metacritic!) : "No Data")"
            gameCell.gameReleasedView.text = (game.released != nil) ? "Released on \(game.released!)" : "Not released yet"
            gameCell.gameImageView.image = UIImage(data: game.image ?? Data())

            if game.state == .new {
                gameCell.gameImageLoadingIndicator.isHidden = false
                gameCell.gameImageLoadingIndicator.startAnimating()
                startDownloadImage(
                    imageUrl: game.backgroundImage,
                    downloadableImage: game,
                    indexPath: indexPath,
                    viewType: .gameTable
                )
            } else {
                gameCell.gameImageLoadingIndicator.stopAnimating()
                gameCell.gameImageLoadingIndicator.isHidden = true
            }

            return gameCell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: "moveToDetail",
            sender: (games[indexPath.row].id, games[indexPath.row].name)
        )
    }
}

// MARK: - Genres Collection Data & UI Utils
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let genreCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "genreCollectionViewCell",
            for: indexPath
        ) as? GenreCollectionViewCell {
            let genre = genres[indexPath.row]

            genreCell.genreLabelView.text = genre.name
            genreCell.genreImageView.image = UIImage(data: genre.image ?? Data())

            if genre.state == .new {
                genreCell.genreImageLoadingVIew.isHidden = false
                genreCell.genreImageLoadingVIew.startAnimating()
                startDownloadImage(
                    imageUrl: genre.imageBackground,
                    downloadableImage: genre,
                    indexPath: indexPath,
                    viewType: .genreCollection
                )
            } else {
                genreCell.genreImageLoadingVIew.stopAnimating()
                genreCell.genreImageLoadingVIew.isHidden = true
            }

            return genreCell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(
            withIdentifier: "moveToGenre",
            sender: (genres[indexPath.row].id, genres[indexPath.row].name)
        )
    }
}

// MARK: - Searchbar UI Utils
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarQuery = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarQuery = nil
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(
            withIdentifier: "moveToGenre",
            sender: searchBarQuery
        )
    }
}
