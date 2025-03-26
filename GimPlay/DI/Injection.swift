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

class Injection {
    static let shared = Injection()
    
    let container: Container
    
    private init() {
        container = Container()
        
        registerDataSource()
        registerRepository()
        registerUseCase()
        registerPresenter()
        registerViewController()
    }
    
    private func registerDataSource() {
        // Prepare Dependencies
        let realm = try? Realm()
        let local: ILocalDataSource = LocalDataSource.sharedInstance(realm)
        let remote: IRemoteDataSource = RemoteDataSource.sharedInstance
        
        // Register DataSource
        container.register(ILocalDataSource.self) { _ in local }
        container.register(IRemoteDataSource.self) { _ in remote }
    }
    
    private func registerRepository() {
        // Register Repository
        container.register(IRepository.self) { r in
            Repository(
                remoteDS: r.resolve(IRemoteDataSource.self)!,
                localDS: r.resolve(ILocalDataSource.self)!
            )
        }
    }
    
    private func registerUseCase() {
        // Register UseCase
        container.register(IGameUseCase.self) { r in
            GameUseCase(repository: r.resolve(IRepository.self)!)
        }
    }
    
    private func registerPresenter() {
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
    }
    
    private func registerViewController() {
        // Register VC
        container.storyboardInitCompleted(ViewController.self) { r, vc in
            vc.presenter = r.resolve(HomePresenter.self)
        }
        container.storyboardInitCompleted(DetailViewController.self) { r, vc in
            vc.presenter = r.resolve(DetailPresenter.self)
        }
        container.storyboardInitCompleted(FavouriteViewController.self) { r, vc in
            vc.presenter = r.resolve(FavouritePresenter.self)
        }
        container.storyboardInitCompleted(GenreViewController.self) { r, vc in
            vc.presenter = r.resolve(GenrePresenter.self)
        }
    }
}
