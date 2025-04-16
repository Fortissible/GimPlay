//
//  Localization.swift
//  Common
//
//  Created by Zahra Nurul Izza on 17/04/25.
//
import Foundation

public struct Localization {
    public static func string(for key: String, table: String? = nil, bundle: Bundle? = nil, comment: String = "") -> String {
        let bundle = bundle ?? Bundle(for: BundleToken.self)
        return NSLocalizedString(key, tableName: table, bundle: bundle, value: key, comment: comment)
    }

    public init() {}

    private final class BundleToken {}
}
