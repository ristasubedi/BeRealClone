//
//  SignUpViewController.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.

import UIKit
import ParseSwift
import PhotosUI

class SignUpViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
    }
    
    // MARK: - Actions
    
    @IBAction func attachPhoto(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {
        // 1. Validation
        guard let usernameText = username.text, !usernameText.isEmpty,
              let emailText = email.text, !emailText.isEmpty,
              let passwordText = password.text, !passwordText.isEmpty else {
            print("DEBUG: ❌ Validation failed - missing fields")
            showMissingFieldsAlert()
            return
        }

        var newUser = User()
        newUser.username = usernameText
        newUser.email = emailText
        newUser.password = passwordText

        // 2. Handle Profile Image Upload first
        if let image = pickedImage,
           let imageData = image.jpegData(compressionQuality: 0.1) {
            
            let imageFile = ParseFile(name: "profile.jpg", data: imageData)
            print("DEBUG: ⏳ Starting profile image upload...")

            // We save the file explicitly to ensure it exists on Back4App before the user is created
            imageFile.save { [weak self] result in
                switch result {
                case .success(let savedFile):
                    print("DEBUG: ✅ Image uploaded successfully to: \(savedFile.url?.absoluteString ?? "No URL")")
                    newUser.image = savedFile
                    // Proceed to signup only after image is safe
                    self?.executeSignup(newUser: newUser)
                    
                case .failure(let error):
                    print("DEBUG: ❌ Image upload failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.showAlert(description: "Image upload failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("DEBUG: ℹ️ No image picked, proceeding with standard signup")
            executeSignup(newUser: newUser)
        }
    }

    private func executeSignup(newUser: User) {
        print("DEBUG: ⏳ Sending user data to Back4App...")
        
        newUser.signup { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("DEBUG: ✅ Successfully signed up user: \(user.username ?? "unknown")")
                    
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)

                    // FIX FOR BLACK SCREEN: Explicitly push the FeedViewController
                    if let feedVC = self?.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController {
                        print("DEBUG: 🚀 Transitioning to FeedViewController")
                        feedVC.modalPresentationStyle = .fullScreen
                        
                        if let nav = self?.navigationController {
                            nav.pushViewController(feedVC, animated: true)
                        } else {
                            self?.present(feedVC, animated: true)
                        }
                    } else {
                        print("DEBUG: ❌ Error: Could not find FeedViewController Storyboard ID")
                    }

                case .failure(let error):
                    print("DEBUG: ❌ Signup failed: \(error.localizedDescription)")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.pickedImage = image
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Oops...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

