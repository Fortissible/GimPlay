//
//  MainTabBarController.swift
//  GimPlay
//
//  Created by Zahra Nurul Izza on 20/04/25.
//

import UIKit
import Common

class MainTabBarController: UITabBarController {

    var localization: LocalizationStringWrapper?

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.items?[0].title = localization?.bottomNavStore ?? "Store"
        tabBar.items?[1].title = localization?.bottomNavFav ?? "Favourite"
        tabBar.items?[2].title = localization?.bottomNavProfile ?? "Profile"
    }
}
