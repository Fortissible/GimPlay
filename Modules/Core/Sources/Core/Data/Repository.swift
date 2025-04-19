//
//  File.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RxSwift

public protocol Repository {
    associatedtype Request
    associatedtype Response

    func execute(request: Request) -> Observable<Response>
}
