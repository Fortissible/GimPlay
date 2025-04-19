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

    @IBOutlet weak var profileSubtitle: UILabel!
    @IBOutlet weak var profileTitle: UINavigationItem!
    @IBOutlet weak var profileDesc: UITextView!
    @IBOutlet weak var profileJobs: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var aboutmeTitle: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!

    var localization: LocalizationStringWrapper?

    override func viewWillAppear(_ animated: Bool) {
        syncProfiles()

        getProfileUserModel()

        profileTitle.title = localization?.profileTitle ?? "Profiles"
        profileSubtitle.text = localization?.profileSubtitle ?? "Hello there, can you see me? right below here!"
        aboutmeTitle.text = localization?.profileAboutTitle ?? "About Me"
        editProfileBtn.setTitle(localization?.profileEditBtnTitle ?? "Edit Profile", for: .normal)
    }

    func syncProfiles() {
        UserModel.sync()
    }

    func getProfileUserModel() {
        profileName.text = UserModel.name!
        profileJobs.text = (localization?.profileJobsPrefix ?? "I'm a") + " \(UserModel.profession!)"
        profileDesc.text = UserModel.desc!

        profileImage.image = (UserModel.image != nil)
        ? UIImage(data: UserModel.image!)
        : UIImage(named: "aboutme")
    }
}
