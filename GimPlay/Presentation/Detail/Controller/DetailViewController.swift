//
//  DetailViewController.swift
//  GimPlay
//
//  Created by Wildan on 12/03/25.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var gameDetailStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gameReleasePlaytime: UILabel!
    @IBOutlet weak var gameIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameGenreList: UIStackView!
    @IBOutlet weak var gameDesc: UILabel!
    @IBOutlet weak var gameStoreList: UIButton!
    @IBOutlet weak var gamePublisher: UILabel!
    @IBOutlet weak var gameReviews: UILabel!
    @IBOutlet weak var gameCartBtn: UIButton!
    
    var gameData: (Int, String)? = nil
    var gameDetails: GameDetailModel? = nil
    var isFavourite: Bool = false
    private var error: String? = nil
    
    var presenter: DetailPresenter?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let (gameId, gameTitle) = gameData {
            self.title = String(gameTitle)
            self.navigationItem.backButtonTitle = ""
            
            if (gameDetails == nil) {
                getGameDetail(
                    String(gameId)
                )
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        bindPresenter()
        
        if (gameDetails == nil) {
            errorText.isHidden = true
            scrollView.isHidden = true
            
            gameDetailStackView.isHidden = true
            gameIndicator.startAnimating()
        }
    }
    
    func bindPresenter() {
        presenter?.gameDetail
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (gameDetail, isFavourite) in
                self?.gameDetails = gameDetail
                self?.isFavourite = isFavourite
                self?.updateUI(detail: gameDetail)
            })
            .disposed(by: disposeBag)
        
        presenter?.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.error = error
                self?.updateUIFromGettingError(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    func getGameDetail(_ id: String) {
        presenter?.getGameDetail(id: id)
    }
    
    func updateUIFromGettingError(error: String) {
        gameIndicator.stopAnimating()
        gameIndicator.isHidden = true
        
        errorText.text = error
        errorText.isHidden = false
        
        self.view.showToast(message: error)
    }
    
    fileprivate func updateUI(detail: GameDetailModel) {
        gamePublisher.text = detail.publisher
        gameReleasePlaytime.text = "Released: \(detail.released), Total playtime: \(detail.playtime) Hours"
        gameReviews.text = "\(detail.rating)/\(detail.ratingTop)★ - Metacritic: \(detail.metacritic) - Reviews: \(detail.reviewsCount)"
        gameDesc.text = detail.description
        gameCartBtn.setImage(
            isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            for: .normal
        )
        
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
        
        gameGenreList.arrangedSubviews.forEach { subview in
            gameGenreList.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
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
        scrollView.isHidden = false
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
    
    @IBAction func onClickFavourite(_ sender: Any) {
        gameDetails != nil && !isFavourite
            ? presenter?.addFavouriteGame(gameDetails!)
            : presenter?.removeFavouriteGame(gameDetails!.id)
        
        self.updateUI(detail: self.gameDetails!)
        self.isFavourite = !isFavourite
    }
}
