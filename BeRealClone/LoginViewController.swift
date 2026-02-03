//
//  LoginViewController.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        password.isSecureTextEntry = true
        super.viewDidLoad()
    }
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    @IBAction func didTapLogIn(_ sender: Any) {
        guard let username = username.text, !username.isEmpty,
              let password = password.text, !password.isEmpty else {
            showMissingFieldsAlert()
            return
        }
        User.login(username: username, password: password) { [weak self] result in

            switch result {
            case .success(let user):
                print("✅ Successfully logged in as user: \(user)")

                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                
                
                if let feedView = self?.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController {
                    feedView.modalPresentationStyle = .fullScreen
                    self?.navigationController?.pushViewController(feedView, animated: true)
                }else {
                    print("Error: unable to instantiate FeedViewController")
                }
                
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }
    

}

