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

    // MARK: - Home
    public var homeSearchHint: String {
        return Localization().string(for: "home-search-hint")
    }

    public var homeCategoriesHint: String {
        Localization().string(for: "home-categories-hint")
    }

    public var homeGameCellRelease: String {
        Localization().string(for: "home-game-cell-release")
    }

    // MARK: - Bottom Navigation
    public var bottomNavStore: String {
        Localization().string(for: "bottom-nav-store")
    }

    public var bottomNavProfile: String {
        Localization().string(for: "bottom-nav-profile")
    }

    public var bottomNavFav: String {
        Localization().string(for: "bottom-nav-fav")
    }

    // MARK: - Detail
    public var detailMetacriticEmpty: String {
        Localization().string(for: "detail-metacritic-empty")
    }

    public var detailNotReleased: String {
        Localization().string(for: "detail-not-released")
    }

    public var detailPlaytimePrefix: String {
        Localization().string(for: "detail-playtime-prefix")
    }

    public var detailReleasedPrefix: String {
        Localization().string(for: "detail-released-prefix")
    }

    public var detailReviewsPrefix: String {
        Localization().string(for: "detail-reviews-prefix")
    }

    public var detailHours: String {
        Localization().string(for: "detail-hours")
    }

    // MARK: - Edit Profile
    public var editProfileAboutTitle: String {
        Localization().string(for: "edit-profile-about-title")
    }

    public var editProfileBtnCancel: String {
        Localization().string(for: "edit-profile-btn-cancel")
    }

    public var editProfileBtnSave: String {
        Localization().string(for: "edit-profile-btn-save")
    }

    public var editProfileJobsPrefix: String {
        Localization().string(for: "edit-profile-jobs-prefix")
    }

    public var editProfileSelectPicture: String {
        Localization().string(for: "edit-profile-select-picture")
    }

    public var editProfileSubtitle: String {
        Localization().string(for: "edit-profile-subtitle")
    }

    public var editJobPlaceholder: String {
        Localization().string(for: "edit-job-placeholder")
    }

    public var editNamePlaceholder: String {
        Localization().string(for: "edit-name-placeholder")
    }

    // MARK: - Favorite
    public var favoriteEmptyTitle: String {
        Localization().string(for: "favorite-empty-title")
    }

    public var favoriteErrorTitle: String {
        Localization().string(for: "favorite-error-title")
    }

    public var favoriteErrorToast: String {
        Localization().string(for: "favorite-error-toast")
    }

    public var favoriteSearchCancel: String {
        Localization().string(for: "favorite-search-cancel")
    }

    public var favoriteSearchPlaceholder: String {
        Localization().string(for: "favorite-search-placeholder")
    }

    public var favoriteTitle: String {
        Localization().string(for: "favorite-title")
    }

    // MARK: - General
    public var generalBackBtn: String {
        Localization().string(for: "general-back-btn")
    }

    public var generalModalFailedDismiss: String {
        Localization().string(for: "general-modal-failed-dismiss")
    }

    public var generalModalFailedInfoImg: String {
        Localization().string(for: "general-modal-failed-info-img")
    }

    public var generalModalFailedTitle: String {
        Localization().string(for: "general-modal-failed-title")
    }

    // MARK: - Profile
    public var profileAboutTitle: String {
        Localization().string(for: "profile-about-title")
    }

    public var profileEditBtnTitle: String {
        Localization().string(for: "profile-edit-btn-title")
    }

    public var profileJobsPrefix: String {
        Localization().string(for: "profile-jobs-prefix")
    }

    public var profileSubtitle: String {
        Localization().string(for: "profile-subtitle")
    }

    public var profileTitle: String {
        Localization().string(for: "profile-title")
    }

    // MARK: - Search
    public var searchResultTitle: String {
        Localization().string(for: "search-result-title")
    }
}
