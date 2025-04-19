//
//  File.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RxSwift

public protocol RemoteDataSource {
    associatedtype Request
    associatedtype Response

    func execute(req: Request) -> Observable<Response>
}
