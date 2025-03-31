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

extension SwinjectStoryboard {
    @objc class func setup() {
        // Define Container
        let container = defaultContainer

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

    class func setupSourceData(container: Container) {
        let realm = try? Realm()
        let local: ILocalDataSource = LocalDataSource.sharedInstance(realm)
        let remote: IRemoteDataSource = RemoteDataSource.sharedInstance

        container.register(ILocalDataSource.self) { _ in local }
        container.register(IRemoteDataSource.self) { _ in remote }
    }

    class func setupRepository(container: Container) {
        container.register(IRepository.self) { resolver in
            Repository(
                remoteDS: resolver.resolve(IRemoteDataSource.self)!,
                localDS: resolver.resolve(ILocalDataSource.self)!
            )
        }
    }

    class func setupUsecase(container: Container) {
        container.register(IGameUseCase.self) { resolver in
            GameUseCase(repository: resolver.resolve(IRepository.self)!)
        }
    }

    class func setupPresenter(container: Container) {
        container.register(HomePresenter.self) { resolver in
            HomePresenter(useCase: resolver.resolve(IGameUseCase.self)!)
        }
        container.register(DetailPresenter.self) { resolver in
            DetailPresenter(useCase: resolver.resolve(IGameUseCase.self)!)
        }
        container.register(FavouritePresenter.self) { resolver in
            FavouritePresenter(useCase: resolver.resolve(IGameUseCase.self)!)
        }
        container.register(GenrePresenter.self) { resolver in
            GenrePresenter(useCase: resolver.resolve(IGameUseCase.self)!)
        }
    }

    class func setupController(container: Container) {
        // Register ViewController
        container.storyboardInitCompleted(ViewController.self) { resolver, viewCon in
            viewCon.presenter = resolver.resolve(HomePresenter.self)
        }
        container.storyboardInitCompleted(FavouriteViewController.self) { resolver, viewCon in
            viewCon.presenter = resolver.resolve(FavouritePresenter.self)
        }
        container.storyboardInitCompleted(DetailViewController.self) { resolver, viewCon in
            viewCon.presenter = resolver.resolve(DetailPresenter.self)
        }
        container.storyboardInitCompleted(GenreViewController.self) { resolver, viewCon in
            viewCon.presenter = resolver.resolve(GenrePresenter.self)
        }
        container.storyboardInitCompleted(ProfileViewController.self) { _, _ in
        }

        // Register UINavigationController
        container.storyboardInitCompleted(UINavigationController.self) { resolver, navCon in
            let viewController = navCon.viewControllers.first

            switch navCon.viewControllers.first {
            case is ViewController:
                (viewController as? ViewController)?.presenter = resolver.resolve(HomePresenter.self)
            case is ProfileViewController:
                print("ProfileViewController Set Up")
            case is FavouriteViewController:
                (viewController as? FavouriteViewController)?.presenter =
                resolver.resolve(FavouritePresenter.self)
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
                        (viewController as? ViewController)?.presenter = resolver.resolve(HomePresenter.self)
                    case is ProfileViewController:
                        print("ProfileViewController Set Up")
                    case is FavouriteViewController:
                        (viewController as? FavouriteViewController)?.presenter =
                        resolver.resolve(FavouritePresenter.self)
                    default:
                        print("VC Not found")
                    }
                }
            }
        }
    }
}
