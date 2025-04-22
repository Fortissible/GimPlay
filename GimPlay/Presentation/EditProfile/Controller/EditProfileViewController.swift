//
//  EditProfileViewController.swift
//  GimPlay
//
//  Created by Wildan on 21/03/25.
//

import UIKit
import Core
import Common

class EditProfileViewController: UIViewController {

    @IBOutlet weak var namePrefix: UILabel!
    @IBOutlet weak var editProfilSubtitle: UILabel!
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editSaveBtn: UIButton!
    @IBOutlet weak var editCancelBtn: UIButton!
    @IBOutlet weak var editDescEditableTextView: UITextView!
    @IBOutlet weak var editJobTextFIeld: UITextField!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var aboutMeTitle: UILabel!
    @IBOutlet weak var editProfileImageBtn: UIButton!

    var localization: LocalizationStringWrapper?

    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary

        editDescEditableTextView.layer.borderWidth = 1.0
        editDescEditableTextView.layer.borderColor = UIColor.lightGray.cgColor
        editDescEditableTextView.layer.cornerRadius = 5.0

        editNameTextField.text = UserModel.name!
        editJobTextFIeld.text = UserModel.profession!
        editDescEditableTextView.text = UserModel.desc!
        editProfileImage.image = (UserModel.image != nil)
        ? UIImage(data: UserModel.image!)
        : UIImage(named: "placeholder")
        editProfileImage.layer.cornerRadius = 8
    }

    override func viewWillAppear(_ animated: Bool) {
        UserModel.sync()

        editProfilSubtitle.text = localization?.editProfileSubtitle ?? "Hello there, can you see me? right below here!"
        editProfileImageBtn.setTitle(localization?.editProfileSelectPicture ?? "Select profile picture", for: .normal)
        editSaveBtn.setTitle(localization?.editProfileBtnSave ?? "Save", for: .normal)
        editCancelBtn.setTitle(localization?.editProfileBtnCancel ?? "Cancel", for: .normal)
        editNameTextField.placeholder = localization?.editNamePlaceholder ?? "Enter your name..."
        editJobTextFIeld.placeholder =
            localization?.editJobPlaceholder ??
            "Enter your job title..."
        aboutMeTitle.text =
        localization?.editProfileAboutTitle ?? "About Me"
        namePrefix.text =
        localization?.editProfileJobsPrefix ?? "I'm a"
    }

    @IBAction func onSelectImageBtnTap(_ sender: Any) {
        self.present(imagePicker, animated: true)
    }

    @IBAction func onEditCancelBtnTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onEditSaveBtnTap(_ sender: Any) {
        UserModel.name = editNameTextField.text
        UserModel.profession = editJobTextFIeld.text
        UserModel.desc = editDescEditableTextView.text
        UserModel.image = editProfileImage.image?.jpegData(compressionQuality: 1.0)

        self.navigationController?.popViewController(animated: true)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let result = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.editProfileImage.contentMode = .scaleAspectFill
            self.editProfileImage.image = result

            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: localization?.generalModalFailedTitle ?? "Failed", message: localization?.generalModalFailedInfoImg ?? "Image can't loaded", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: localization?.generalModalFailedDismiss ?? "Dismiss", style: .cancel))

            self.present(alert, animated: true)
        }
    }
}
