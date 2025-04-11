//
//  File.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RxSwift

public protocol LocalDataSource {
    associatedtype ListRequest
    associatedtype ModelRequest
    associatedtype Response

    func getList(request: ListRequest?) -> Observable<[Response]>
    func getDetail(id: Int) -> Observable<Response>
    func add(entity: ModelRequest) -> Observable<Bool>
    func delete(id: Int?) -> Observable<Bool>
    func check(id: Int) -> Observable<Bool>
}
