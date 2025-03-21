//
//  EditProfileViewController.swift
//  GimPlay
//
//  Created by Wildan on 21/03/25.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editSaveBtn: UIButton!
    @IBOutlet weak var editCancelBtn: UIButton!
    @IBOutlet weak var editDescEditableTextView: UITextView!
    @IBOutlet weak var editJobTextFIeld: UITextField!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var editProfileImageBtn: UIButton!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserModel.sync()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let result = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.editProfileImage.contentMode = .scaleAspectFill
            self.editProfileImage.image = result
            
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Failed", message: "Image can't loaded", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
}
