//
//  DataMapper.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation

public protocol DataMapper {
    associatedtype Response
    associatedtype Entity
    associatedtype Domain

    func transformResponseToEntity(response: Response) -> Entity
    func transformEntityToDomain(entity: Entity) -> Domain
}
