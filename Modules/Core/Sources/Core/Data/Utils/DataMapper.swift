//
//  DataMapper.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation

public protocol DataMapper {
    associatedtype Response
    associatedtype Entities
    associatedtype Domain

    func transformResponseToDomain(response: Response) -> Domain
    func transformEntitiesToDomain(entities: Entities) -> Domain
}
