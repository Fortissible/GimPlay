//
//  Result+Ext.swift
//  Core
//
//  Created by Zahra Nurul Izza on 11/04/25.
//

import Foundation
import RealmSwift

extension Results {
    public func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for index in 0..<count {
            if let value = self[index] as? T {
                array.append(value)
            }
        }
        return array
    }
}
