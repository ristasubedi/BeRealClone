//
//  AttachViewController.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class AttachViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    private var location: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapPhoto(_ sender: Any) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        view.endEditing(true)
        
        // 1. Validate User is Logged In
        guard let currentUser = User.current else {
            self.showAlert(description: "You must be logged in to post.")
            return
        }
        
        // 2. Validate Image
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            self.showAlert(description: "Please select a photo first!")
            return
        }

        // Show loading indicator
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)

        // 3. Prepare Parse File and Post
        let imageFile = ParseFile(name: "post_image.jpg", data: imageData)
        var post = Post()
        
        post.imageFile = imageFile
        post.caption = caption.text
        post.location = location
        
        post.user = currentUser

        // 4. Save
        post.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedPost):
                    print("✅ Post Saved Successfully! ID: \(savedPost.objectId ?? "")")
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    // Put the button back if it fails
                    self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(self?.didTapShare(_:)))
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        // 1. Handle Location Metadata
        if let assetIdentifier = result.assetIdentifier {
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
            if let assetLocation = asset?.location {
                reverseGeocode(assetLocation)
            }
        }
        
        // 2. Handle Image Loading
        let provider = result.itemProvider
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.previewImageView.image = image
                        self?.pickedImage = image
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                self?.location = city.isEmpty ? country : "\(city), \(country)"
                print("📍 Location found: \(self?.location ?? "Unknown")")
            }
        }
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: description ?? "Please try again...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
