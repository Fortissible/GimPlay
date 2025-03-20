//
//  FavouriteViewController.swift
//  GimPlay
//
//  Created by Wildan on 19/03/25.
//

import UIKit

class FavouriteViewController: UIViewController {

    @IBOutlet weak var mainInfoLabel: UILabel!
    @IBOutlet weak var genreLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favGameCollectionView: UICollectionView!
    @IBOutlet weak var favGenreCollectionView: UICollectionView!
    
    private var searchBarQuery: String? = nil
    
    private var games: [GameModel] = []
    private var genres: [GenreModel] = []
    
    private let remoteDS: RemoteDataSource = RemoteDataSource()
    private let localDS: LocalDataSource = LocalDataSource()
    private lazy var repository: IRepository = Repository(remoteDS: remoteDS, localDS: localDS)
    private lazy var gameUseCase: GameUseCase = GameUseCase(repository: repository)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favGameCollectionView.delegate = self
        favGameCollectionView.dataSource = self
        
        favGenreCollectionView.delegate = self
        favGenreCollectionView.dataSource = self
        
        createSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gameLoadingIndicator.startAnimating()
        genreLoadingIndicator.startAnimating()
        
        mainInfoLabel.isHidden = true
        
        Task {
            await getGames()
            await getGenres()
        }
    }
    
    func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search your favourite games..."
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    
    func getGames() async {
        do {
            games = try await gameUseCase.getFavouriteGames()
            print("TOTAL LOCAL GAME is: \(games.count)")
            gameLoadingIndicator.stopAnimating()
            gameLoadingIndicator.isHidden = true
            
            if games.isEmpty {
                mainInfoLabel.isHidden = false
                mainInfoLabel.text = "There's no favourite game yet, Browse and add new favourite games now!"
            }
            
            favGameCollectionView.reloadData()
        } catch {
            gameLoadingIndicator.stopAnimating()
            gameLoadingIndicator.isHidden = true
            print("DEBUG ERROR WHEN GET LOCAL GAMES \(error.localizedDescription)")
            
            mainInfoLabel.isHidden = false
            mainInfoLabel.textColor = .red
            mainInfoLabel.text = "Error occured: \(error.localizedDescription)"
            
            self.view.showToast(message: error.localizedDescription)
        }
    }
    
    func getGenres() async {
        do {
            genres = try await gameUseCase.getFavouriteGenres()
            print("TOTAL LOCAL GENRES is: \(genres.count)")
            genreLoadingIndicator.stopAnimating()
            genreLoadingIndicator.isHidden = true
            
            favGenreCollectionView.reloadData()
        } catch {
            genreLoadingIndicator.stopAnimating()
            genreLoadingIndicator.isHidden = true
            print("DEBUG ERROR WHEN GET LOCAL GAMES \(error.localizedDescription)")
            self.view.showToast(message: error.localizedDescription)
        }
    }
    
    fileprivate func startDownloadImage(
        imageUrl: String?,
        downloadableImage: DownloadableImage,
        indexPath: IndexPath,
        viewType: ViewType
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
                        switch viewType {
                        case .gameTable:
                            self.favGameCollectionView.reloadItems(at: [indexPath])
                        case .genreCollection:
                            self.favGenreCollectionView.reloadItems(at: [indexPath])
                        }
                    }
                } catch {
                    downloadableImage.state = .failed
                    downloadableImage.image = UIImage(named: "placeholder")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "moveToDetailFromFavourite":
                if let detailViewController = segue.destination as? DetailViewController {
                    detailViewController.gameData = sender as? (Int, String)
                }
                break
            default:
                break
        }
    }
    
    @objc fileprivate func favButtonTapped(_ sender: UIButton) {
        let selectedGameId = games[sender.tag].id
        Task {
            try await gameUseCase.removeFavouriteGame(selectedGameId)
            games = try await gameUseCase.getFavouriteGames()
            genres = try await gameUseCase.getFavouriteGenres()
            self.favGameCollectionView.reloadData()
            self.favGenreCollectionView.reloadData()
        }
    }
}

extension FavouriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case favGameCollectionView:
                return games.count
            case favGenreCollectionView:
                return genres.count
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
            case favGameCollectionView:
                if let gameCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "favGameCollectionViewCell",
                    for: indexPath
                ) as? FavGameCollectionViewCell {
                    let game = games[indexPath.row]
                    
                    gameCell.favGameButton.setImage(
                        game.isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
                        for: .normal
                    )
                    gameCell.favGameButton.tag = indexPath.row
                    gameCell.favGameButton.addTarget(
                        self,
                        action: #selector(favButtonTapped(_:)),
                        for: .touchUpInside
                    )
                    gameCell.favGameImageView.image = game.image
                    gameCell.favGameLabel.text = game.name
                    
                    if game.state == .new {
                        gameCell.favGameImageView.isHidden = false
                        gameCell.favGameLoadingIndicator.startAnimating()
                        startDownloadImage(
                            imageUrl: game.backgroundImage,
                            downloadableImage: game,
                            indexPath: indexPath,
                            viewType: .gameTable
                        )
                    } else {
                        gameCell.favGameLoadingIndicator.stopAnimating()
                        gameCell.favGameLoadingIndicator.isHidden = true
                    }
                    
                    return gameCell
                } else {
                    return UICollectionViewCell()
                }
            case favGenreCollectionView:
                if let genreCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "favGenreCollectionViewCell",
                    for: indexPath
                ) as? FavGenreCollectionViewCell {
                    let genre = genres[indexPath.row]
                    
                    genreCell.genreLabelView.text = genre.name
                    genreCell.genreImageView.image = genre.image
                    
                    if genre.state == .new {
                        genreCell.genreImageView.isHidden = false
                        genreCell.genreImageIndicatorView.startAnimating()
                        startDownloadImage(
                            imageUrl: genre.imageBackground,
                            downloadableImage: genre,
                            indexPath: indexPath,
                            viewType: .genreCollection
                        )
                    } else {
                        genreCell.genreImageIndicatorView.stopAnimating()
                        genreCell.genreImageIndicatorView.isHidden = true
                    }

                    return genreCell
                } else {
                    return UICollectionViewCell()
                }
            default:
                return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == favGameCollectionView {
            performSegue(
                withIdentifier: "moveToDetailFromFavourite",
                sender: (games[indexPath.row].id, games[indexPath.row].name)
            )
        } else {
            // TODO: FETCH FAVOURITE GAMES WITH GENRE FILTER
        }
    }
}

extension FavouriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == favGameCollectionView {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (favGameCollectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 240)
        } else {
            return CGSize(width: 140, height: 100)
        }
    }
}

// MARK: - Searchbar UI Utils
extension FavouriteViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarQuery = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO: FETCH DATA FROM COREDATA BASED ON SEARCH QUERY
    }
}
