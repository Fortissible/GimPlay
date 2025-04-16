//
//  Injection.swift
//  GimPlay
//
//  Created by Wildan on 25/03/25.
//

import Foundation
import Swinject
import RealmSwift
import SwinjectStoryboard
import UIKit
import Core
import Game
import GameDetail
import Genre
import Common

extension SwinjectStoryboard {
    @objc class func setup() {
        // Define Container
        let container = defaultContainer

        // Register Localization Module
        self.setupLocalization(container: container)

        // Register DataSource
        self.setupSourceData(container: container)

        // Register Repository
        self.setupRepository(container: container)

        // Register UseCase
        self.setupUsecase(container: container)

        // Register Presenters
        self.setupPresenter(container: container)

        // Register Controller
        self.setupController(container: container)
    }

    class func setupLocalization(container: Container) {
        container.register(Localization.self) { _ in
            Localization()
        }
    }

    class func setupSourceData(container: Container) {
        let realm = try? Realm()

        // Modules
        let gameLocal: GameLocalDataSource = GameLocalDataSource(realm: realm)
        let gameRemote: GameRemoteDataSource = GameRemoteDataSource()
        let gameDetailLocal: GameDetailLocalDataSource = GameDetailLocalDataSource(realm: realm)
        let gameDetailRemote: GameDetailRemoteDataSource = GameDetailRemoteDataSource()
        let genreLocal: GenreLocalDataSource = GenreLocalDataSource(realm: realm)
        let genreRemote: GenreRemoteDataSource = GenreRemoteDataSource()

        container.register(GameLocalDataSource.self) { _ in gameLocal }
        container.register(GameRemoteDataSource.self) { _ in gameRemote }
        container.register(GameDetailLocalDataSource.self) { _ in gameDetailLocal }
        container.register(GameDetailRemoteDataSource.self) { _ in gameDetailRemote }
        container.register(GenreLocalDataSource.self) { _ in genreLocal }
        container.register(GenreRemoteDataSource.self) { _ in genreRemote }
    }

    class func setupRepository(container: Container) {
        // Modules
        container.register(GameRepository.self) { resolver in
            GameRepository(
                localDataSource: resolver.resolve(GameLocalDataSource.self)!,
                remoteDataSource: resolver.resolve(GameRemoteDataSource.self)!,
                dataMapper: GameDataMapper()
            )
        }
        container.register(GameDetailRepository.self) { resolver in
            GameDetailRepository(
                localDataSource: resolver.resolve(GameDetailLocalDataSource.self)!,
                remoteDataSource: resolver.resolve(GameDetailRemoteDataSource.self)!,
                dataMapper: GameDetailDataMapper()
            )
        }
        container.register(GenreRepository.self) { resolver in
            GenreRepository(
                localDS: resolver.resolve(GenreLocalDataSource.self)!,
                remoteDS: resolver.resolve(GenreRemoteDataSource.self)!,
                mapper: GenreDataMapper()
            )
        }
    }

    class func setupUsecase(container: Container) {
        // Modules
        container.register(GameInteractor.self) { resolver in
            GameInteractor(repository: resolver.resolve(GameRepository.self)!)
        }

        container.register(GameDetailInteractor.self) { resolver in
            GameDetailInteractor(repository: resolver.resolve(GameDetailRepository.self)!)
        }

        container.register(GenreInteractor.self) { resolver in
            GenreInteractor(repository: resolver.resolve(GenreRepository.self)!)
        }
    }

    class func setupPresenter(container: Container) {
        // Modules
        container.register(GamePresenter<GameInteractor>.self) { resolver in
            GamePresenter(useCase: resolver.resolve(GameInteractor.self)!)
        }

        container.register(GameDetailPresenter<GameDetailInteractor>.self) { resolver in
            GameDetailPresenter(useCase: resolver.resolve(GameDetailInteractor.self)!)
        }

        container.register(GenresPresenter<GenreInteractor>.self) { resolver in
            GenresPresenter(useCase: resolver.resolve(GenreInteractor.self)!)
        }
    }

    class func setupController(container: Container) {
        // Register ViewController
        container.storyboardInitCompleted(ViewController.self) { resolver, viewCon in
            viewCon.gamePresenter = resolver.resolve(GamePresenter.self)
            viewCon.genrePresenter = resolver.resolve(GenresPresenter.self)
            viewCon.localization = resolver.resolve(Localization.self)
        }
        container.storyboardInitCompleted(FavouriteViewController.self) { resolver, viewCon in
            viewCon.gamePresenter = resolver.resolve(GamePresenter.self)
            viewCon.detailPresenter = resolver.resolve(GameDetailPresenter.self)
            viewCon.genrePresenter = resolver.resolve(GenresPresenter.self)
            viewCon.localization = resolver.resolve(Localization.self)
        }
        container.storyboardInitCompleted(DetailViewController.self) { resolver, viewCon in
            viewCon.genrePresenter = resolver.resolve(GenresPresenter.self)
            viewCon.detailPresenter = resolver.resolve(GameDetailPresenter.self)
            viewCon.localization = resolver.resolve(Localization.self)
        }
        container.storyboardInitCompleted(GenreViewController.self) { resolver, viewCon in
            viewCon.presenter = resolver.resolve(GamePresenter.self)
            viewCon.localization = resolver.resolve(Localization.self)
        }
        container.storyboardInitCompleted(ProfileViewController.self) { resolver, viewCon in
            viewCon.localization = resolver.resolve(Localization.self)
        }
        container.storyboardInitCompleted(EditProfileViewController.self) { resolver, viewCon in
            viewCon.localization = resolver.resolve(Localization.self)
        }

        // Register UINavigationController
        container.storyboardInitCompleted(UINavigationController.self) { resolver, navCon in
            let viewController = navCon.viewControllers.first

            switch navCon.viewControllers.first {
            case is ViewController:
                (viewController as? ViewController)?.gamePresenter = resolver.resolve(GamePresenter.self)
                (viewController as? ViewController)?.genrePresenter = resolver.resolve(GenresPresenter.self)
                (viewController as? ViewController)?.localization = resolver.resolve(Localization.self)
            case is ProfileViewController:
                (viewController as? ProfileViewController)?.localization = resolver.resolve(Localization.self)
            case is FavouriteViewController:
                (viewController as? FavouriteViewController)?.gamePresenter = resolver.resolve(GamePresenter.self)
                (viewController as? FavouriteViewController)?.genrePresenter = resolver.resolve(GenresPresenter.self)
                (viewController as? FavouriteViewController)?.detailPresenter = resolver.resolve(GameDetailPresenter.self)
                (viewController as? FavouriteViewController)?.localization = resolver.resolve(Localization.self)
            default:
                print("VC Not found")
            }
        }

        // Register UITabBarController
        container.storyboardInitCompleted(UITabBarController.self) { resolver, tabBarController in
            // Iterate over the view controllers inside UITabBarController
            for child in tabBarController.viewControllers ?? [] {
                if let navController = child as? UINavigationController {
                    let viewController = navController.viewControllers.first

                    switch navController.viewControllers.first {
                    case is ViewController:
                        (viewController as? ViewController)?.gamePresenter = resolver.resolve(GamePresenter.self)
                        (viewController as? ViewController)?.genrePresenter = resolver.resolve(GenresPresenter.self)
                        (viewController as? ViewController)?.localization = resolver.resolve(Localization.self)
                    case is ProfileViewController:
                        (viewController as? ProfileViewController)?.localization = resolver.resolve(Localization.self)
                    case is FavouriteViewController:
                        (viewController as? FavouriteViewController)?.gamePresenter = resolver.resolve(GamePresenter.self)
                        (viewController as? FavouriteViewController)?.genrePresenter = resolver.resolve(GenresPresenter.self)
                        (viewController as? FavouriteViewController)?.detailPresenter = resolver.resolve(GameDetailPresenter.self)
                        (viewController as? FavouriteViewController)?.localization = resolver.resolve(Localization.self)
                    default:
                        print("VC Not found")
                    }
                }
            }
        }
    }
}
