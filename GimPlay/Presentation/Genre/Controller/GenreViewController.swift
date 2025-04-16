//
//  GenreViewController.swift
//  GimPlay
//
//  Created by Wildan on 12/03/25.
//

import UIKit
import RxSwift
import Core
import Game
import Common

class GenreViewController: UIViewController {

    @IBOutlet weak var textError: UILabel!
    @IBOutlet weak var gameByGenreIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameByGenreTableView: UITableView!

    var searchQueryData: String?
    var genreData: (Int, String)?
    var games: [Core.GameModel] = []
    private var error: String?

    var localization: Localization?
    var presenter: GamePresenter<GameInteractor>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        gameByGenreTableView.dataSource = self
        gameByGenreTableView.register(
            UINib(nibName: "GameCardViewCell", bundle: nil),
            forCellReuseIdentifier: "gameCardViewCell"
        )
        gameByGenreTableView.delegate = self

        if let (genreId, genreTitle) = genreData {

            self.title = "\(genreTitle) Genre"

            if games.isEmpty {
                getGamesByGenre(String(genreId))
            } else {
                self.gameByGenreIndicator.stopAnimating()
                self.gameByGenreIndicator.isHidden = true
            }
        }

        if let searchQueryResult = searchQueryData {

            self.title = "Search: \(searchQueryResult)"

            if games.isEmpty {
                getGamesBySearchQuery(searchQueryResult)
            } else {
                self.gameByGenreIndicator.stopAnimating()
                self.gameByGenreIndicator.isHidden = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        textError.isHidden = true
        gameByGenreIndicator.startAnimating()

        bindPresenter()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToDetailFromGenre" {
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.gameData = sender as? (Int, String)
            }
        }
    }

    private func bindPresenter() {
        presenter?.games
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { games in
                    self.games.append(contentsOf: games)
                    self.hideIndicatorUI()
                    self.gameByGenreTableView.reloadData()
                }
            )
            .disposed(by: disposeBag)

        presenter?.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.error = error
                self.hideIndicatorUI()
                self.updateUIFromGettingError(error: error)
            })
            .disposed(by: disposeBag)
    }

    func getGamesByGenre(_ genreId: String) {
        presenter?.execute(request: GamePresenterRequest.fetchGames("lucky", genreId, nil))
    }

    func getGamesBySearchQuery(_ searchQuery: String?) {
        presenter?.execute(request: GamePresenterRequest.fetchGames("lucky", nil, searchQuery))
    }

    func hideIndicatorUI() {
        gameByGenreIndicator.stopAnimating()
        gameByGenreIndicator.isHidden = true
    }

    func updateUIFromGettingError(error: String) {
        if games.isEmpty {
            textError.text = error
            textError.isHidden = false
        }

        self.view.showToast(message: error)
    }
}

extension GenreViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let offset = scrollView.contentOffset.y

        if offset > contentHeight - scrollViewHeight - 100 {
            if games.count > 0 {
                if genreData != nil {
                    getGamesByGenre(String(genreData?.0 ?? 0))
                } else if searchQueryData != nil {
                    getGamesBySearchQuery(searchQueryData)
                }
            }
        }
    }
}

// MARK: - Games By Genres & Search Query Table View Data & UI Utils
extension GenreViewController: UITableViewDataSource, UITableViewDelegate {
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
                    indexPath: indexPath
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
            withIdentifier: "moveToDetailFromGenre",
            sender: (
                games[indexPath.row].id,
                games[indexPath.row].name
            )
        )
    }

    fileprivate func startDownloadImage(
        imageUrl: String?,
        downloadableImage: Core.DownloadableImage,
        indexPath: IndexPath
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
                        self.gameByGenreTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                } catch {
                    downloadableImage.state = .failed
                    downloadableImage.image = UIImage(named: "placeholder")?.jpegData(compressionQuality: 1)
                }
            }
        }
    }
}
