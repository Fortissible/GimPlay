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
        
        // Prepare Dependencies
        let realm = try? Realm()
        let local: ILocalDataSource = LocalDataSource.sharedInstance(realm)
        let remote: IRemoteDataSource = RemoteDataSource.sharedInstance
        
        // Register DataSource
        container.register(ILocalDataSource.self) { _ in local }
        container.register(IRemoteDataSource.self) { _ in remote }
        
        // Register Repository
        container.register(IRepository.self) { r in
            Repository(
                remoteDS: r.resolve(IRemoteDataSource.self)!,
                localDS: r.resolve(ILocalDataSource.self)!
            )
        }
        
        // Register UseCase
        container.register(IGameUseCase.self) { r in
            GameUseCase(repository: r.resolve(IRepository.self)!)
        }
        
        // Register Presenters
        container.register(HomePresenter.self) { r in
            HomePresenter(useCase: r.resolve(IGameUseCase.self)!)
        }
        container.register(DetailPresenter.self) { r in
            DetailPresenter(useCase: r.resolve(IGameUseCase.self)!)
        }
        container.register(FavouritePresenter.self) { r in
            FavouritePresenter(useCase: r.resolve(IGameUseCase.self)!)
        }
        container.register(GenrePresenter.self) { r in
            GenrePresenter(useCase: r.resolve(IGameUseCase.self)!)
        }
        
        // Register VC
        container.storyboardInitCompleted(ViewController.self) { r, vc in
            vc.presenter = r.resolve(HomePresenter.self)
        }
        container.storyboardInitCompleted(FavouriteViewController.self) { r, vc in
            vc.presenter = r.resolve(FavouritePresenter.self)
        }
        container.storyboardInitCompleted(DetailViewController.self) { r, vc in
            vc.presenter = r.resolve(DetailPresenter.self)
        }
        container.storyboardInitCompleted(GenreViewController.self) { r, vc in
            vc.presenter = r.resolve(GenrePresenter.self)
        }
        container.storyboardInitCompleted(ProfileViewController.self) { _,_ in
        }
        
        // Register UINavigationController
        container.storyboardInitCompleted(UINavigationController.self) { r, nv in
            let viewController = nv.viewControllers.first
            
            switch nv.viewControllers.first {
            case is ViewController:
                (viewController as? ViewController)?.presenter = r.resolve(HomePresenter.self)
                break
            case is ProfileViewController:
                break
            case is FavouriteViewController:
                (viewController as? FavouriteViewController)?.presenter =
                r.resolve(FavouritePresenter.self)
                break
            default:
                print("VC Not found")
            }
        }
        
        // Register UITabBarController
        container.storyboardInitCompleted(UITabBarController.self) { r, tabBarController in
            // Iterate over the view controllers inside UITabBarController
            for child in tabBarController.viewControllers ?? [] {
                if let navController = child as? UINavigationController {
                    let viewController = navController.viewControllers.first
                    
                    switch navController.viewControllers.first {
                    case is ViewController:
                        (viewController as? ViewController)?.presenter = r.resolve(HomePresenter.self)
                        break
                    case is ProfileViewController:
                        break
                    case is FavouriteViewController:
                        (viewController as? FavouriteViewController)?.presenter =
                        r.resolve(FavouritePresenter.self)
                        break
                    default:
                        print("VC Not found")
                    }
                }
            }
        }
    }
}
