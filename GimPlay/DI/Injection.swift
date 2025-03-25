//
//  Injection.swift
//  GimPlay
//
//  Created by Wildan on 25/03/25.
//

import Foundation
import Swinject

class Injection {
    static let shared = Injection()
    
    let container: Container
    
    private init() {
        container = Container()
        container.register(LocalDataSource.self) { _ in LocalDataSource() }
        container.register(RemoteDataSource.self) { _ in RemoteDataSource() }
        container.register(IRepository.self) { r in
            Repository(
                remoteDS: r.resolve(RemoteDataSource.self)!,
                localDS: r.resolve(LocalDataSource.self)!
            )
        }
        container.register(IGameUseCase.self) { r in
            GameUseCase(repository: r.resolve(IRepository.self)!)
        }
    }
}
