//
//  File.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//
import RxSwift

public protocol Presenter {
    associatedtype Request
    associatedtype Response

    func execute(request: Request)
}
