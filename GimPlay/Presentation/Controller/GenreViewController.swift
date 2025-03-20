//
//  GenreViewController.swift
//  GimPlay
//
//  Created by Wildan on 12/03/25.
//

import UIKit

class GenreViewController: UIViewController {
    
    @IBOutlet weak var textError: UILabel!
    @IBOutlet weak var gameByGenreIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameByGenreTableView: UITableView!
    
    var searchQueryData: String? = nil
    var genreData: (Int, String)? = nil
    var games: [GameModel] = []
    
    private let remoteDS: RemoteDataSource = RemoteDataSource()
    private let localDS: LocalDataSource = LocalDataSource()
    private lazy var repository: IRepository = Repository(remoteDS: remoteDS, localDS: localDS)
    private lazy var gameUseCase: GameUseCase = GameUseCase(repository: repository)

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
            
            Task {
                if games.isEmpty {
                    await getGamesByGenre(String(genreId))
                } else {
                    DispatchQueue.main.async {
                        self.gameByGenreIndicator.stopAnimating()
                        self.gameByGenreIndicator.isHidden = true
                    }
                }
            }
        }
        
        if let searchQueryResult = searchQueryData {
            
            self.title = "Search: \(searchQueryResult)"
            
            Task {
                if games.isEmpty {
                    await getGamesBySearchQuery(searchQueryResult)
                } else {
                    DispatchQueue.main.async {
                        self.gameByGenreIndicator.stopAnimating()
                        self.gameByGenreIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textError.isHidden = true
        gameByGenreIndicator.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveToDetailFromGenre" {
            if let detailViewController = segue.destination as? DetailViewController {
                detailViewController.gameData = sender as? (Int, String)
            }
        }
    }
    
    func getGamesByGenre(_ genreId: String) async {
        do {
            games = try await gameUseCase.getGameList(query: "lucky", genreId: genreId, searchQuery: nil)
            
            gameByGenreIndicator.stopAnimating()
            gameByGenreIndicator.isHidden = true
            
            gameByGenreTableView.reloadData()
        } catch {
            gameByGenreIndicator.stopAnimating()
            gameByGenreIndicator.isHidden = true
            
            textError.text = error.localizedDescription
            textError.isHidden = false
            
            self.view.showToast(message: error.localizedDescription)
        }
    }
    
    func getGamesBySearchQuery(_ searchQuery: String?) async {
        do {
            games = try await gameUseCase.getGameList(query: "lucky", genreId: nil, searchQuery: searchQuery)
            
            gameByGenreIndicator.stopAnimating()
            gameByGenreIndicator.isHidden = true
            
            gameByGenreTableView.reloadData()
        } catch {
            gameByGenreIndicator.stopAnimating()
            gameByGenreIndicator.isHidden = true
            
            textError.text = error.localizedDescription
            textError.isHidden = false
            
            self.view.showToast(message: error.localizedDescription)
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
            gameCell.gameImageView.image = game.image

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
        downloadableImage: DownloadableImage,
        indexPath: IndexPath
    ) {
        let imageDownloader = ImageDownloader()
        
        if downloadableImage.state == .new {
            Task {
                do {
                    downloadableImage.state = .downloading
                    
                    let image = try await imageDownloader.downloadImage(
                        url: URL(string: imageUrl ?? "https://placehold.co/600x400.png")!
                    )
                    
                    downloadableImage.state = .done
                    downloadableImage.image = image
                    
                    DispatchQueue.main.async {
                        self.gameByGenreTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                } catch {
                    downloadableImage.state = .failed
                    downloadableImage.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}
