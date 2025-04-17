//
//  ProfileViewController.swift
//  GimPlay
//
//  Created by Wildan on 21/03/25.
//

import UIKit
import Core
import Common

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileDesc: UITextView!
    @IBOutlet weak var profileJobs: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    var localization: LocalizationStringWrapper?

    override func viewWillAppear(_ animated: Bool) {
        syncProfiles()

        getProfileUserModel()
    }

    func syncProfiles() {
        UserModel.sync()
    }

    func getProfileUserModel() {
        profileName.text = UserModel.name!
        profileJobs.text = "I'm a \(UserModel.profession!)"
        profileDesc.text = UserModel.desc!

        profileImage.image = (UserModel.image != nil)
        ? UIImage(data: UserModel.image!)
        : UIImage(named: "aboutme")
    }
}
