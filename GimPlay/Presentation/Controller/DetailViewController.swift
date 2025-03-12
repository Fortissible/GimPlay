//
//  DetailViewController.swift
//  GimPlay
//
//  Created by Wildan on 12/03/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var gameDetailStackView: UIStackView!
    @IBOutlet weak var gameIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameGenreList: UIStackView!
    @IBOutlet weak var gameDesc: UILabel!
    @IBOutlet weak var gameStoreList: UIButton!
    @IBOutlet weak var gamePublisher: UILabel!
    @IBOutlet weak var gameReviews: UILabel!
    @IBOutlet weak var gameCartBtn: UIButton!
    
    var gameData: (Int, String)? = nil
    
    private let remoteDS: RemoteDataSource = RemoteDataSource()
    private lazy var repository: IRepository = Repository(remoteDS: remoteDS)
    private lazy var gameUseCase: GameUseCase = GameUseCase(repository: repository)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let (gameId, gameTitle) = gameData {
            self.title = String(gameTitle)
            
            Task {
                await getGameDetail(
                    String(gameId)
                )
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gameDetailStackView.isHidden = true
        gameIndicator.startAnimating()
    }
    
    func getGameDetail(_ id: String) async {
        do {
            let gameDetails = try await gameUseCase.getGameDetail(id: id)
            DispatchQueue.main.async {
                self.updateUI(detail: gameDetails)
            }
        } catch {
            fatalError("Error while fetching game detail \(error.localizedDescription)")
        }
    }
    
    fileprivate func updateUI(detail: GameDetailModel) {
        gamePublisher.text = detail.publisher
        gameReviews.text = "\(detail.rating)/\(detail.ratingTop)★ - Metacritic: \(detail.metacritic) - Reviews: \(detail.reviewsCount) - Playtime: \(detail.playtime) Hours"
        gameDesc.text = detail.description
        var gameStores = ""
        for (idx, storeName) in
            detail.stores.enumerated() {
            gameStores += storeName.split(separator: " ").first ?? ""
            if idx >= 2 {
                break
            }
            if (idx != detail.stores.count - 1) {
                gameStores += ", "
            }
        }
        gameStoreList.setTitle("On \(gameStores)", for: .normal)
        
        gameGenreList.spacing = 8
        for genre in detail.genres {
            let genreCard = UILabel()
            genreCard.text = genre.name
            genreCard.textAlignment = .center
            genreCard.textColor = .white
            genreCard.backgroundColor = .systemBlue
            genreCard.layer.cornerRadius = 10
            genreCard.layer.masksToBounds = true
            genreCard.heightAnchor.constraint(equalToConstant: 32).isActive = true
            genreCard.widthAnchor.constraint(equalToConstant: 100).isActive = true
            genreCard.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            genreCard.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            gameGenreList.addArrangedSubview(genreCard)
        }
        
        startDownloadImage(
            imageUrl: detail.backgroundImage,
            downloadableImage: detail
        )
        
        gameIndicator.stopAnimating()
        gameIndicator.isHidden = true
        gameDetailStackView.isHidden = false
    }
    
    fileprivate func startDownloadImage(
        imageUrl: String?,
        downloadableImage: DownloadableImage
    ) {
        let imageDownloader = ImageDownloader()
        
        if downloadableImage.state == .new {
            Task {
                do {
                    downloadableImage.state = .downloading
                    
                    let image = try await imageDownloader.downloadImage(
                        url: URL(string: imageUrl ?? "https://placehold.co/600x400.png")!
                    )
                    
                    DispatchQueue.main.async {
                        self.gameImage.image = image
                        downloadableImage.state = .done
                    }
                    
                } catch {
                    downloadableImage.state = .failed
                    downloadableImage.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}
