//
//  Localization.swift
//  Common
//
//  Created by Zahra Nurul Izza on 17/04/25.
//
import Foundation

public class Localization {
    // Explicit bundle reference
    private var bundle: Bundle = {
        // Try multiple ways to get the correct bundle
        let candidates = [
            // Bundle should be here if using SPM
            Bundle.module,
            // Fallback for other integration methods
            Bundle(for: BundleToken.self)
        ]

        for candidate in candidates {
            let path = candidate.path(forResource: "Localizable", ofType: "strings")
            if path != nil {
                return candidate
            }
        }
        fatalError("Unable to find bundle containing Localizable strings")
    }()

    public func string(for key: String, table: String? = nil, comment: String = "") -> String {
        NSLocalizedString(
            key,
            tableName: table,
            bundle: bundle,
            value: key,  // Fallback to key if not found
            comment: comment
        )
    }

    private final class BundleToken {}
}

public class LocalizationStringWrapper {
    public init() {}

    public var homeSearchHint: String {
        return Localization().string(for: "home-search-hint")
    }
    public var homeCategoriesHint: String {
        Localization().string(for: "home-categories-hint")
    }
    public var bottomNavStore: String {
        Localization().string(for: "bottom-nav-store")
    }
    public var bottomNavProfile: String {
        Localization().string(for: "bottom-nav-profile")
    }
    public var bottomNavFav: String {
        Localization().string(for: "bottom-nav-fav")
    }
}
