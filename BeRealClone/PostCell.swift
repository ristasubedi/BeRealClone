//
//  PostCell.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//



import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private var imageDataRequest: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func configure(with post: Post) {
        usernameLabel.text = "Loading..."
        captionLabel.text = ""
        dateLabel.text = ""
        postImageView.image = nil
        profileImageView.image = UIImage(systemName: "person.circle")

        if let user = post.user {
            let name = user.username ?? "Unknown"
            if let location = post.location, !location.isEmpty {
                usernameLabel.text = "\(name) is in \(location)"
            } else {
                usernameLabel.text = name
            }

            if let profileImage = user.image, let imageUrl = profileImage.url {
                profileImageView.af.setImage(withURL: imageUrl, placeholderImage: UIImage(systemName: "person.circle"))
            }
        } else {
            usernameLabel.text = "Anonymous Post"
            print("⚠️ Warning: Post \(post.objectId ?? "") is missing a user pointer.")
        }

        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            postImageView.af.setImage(withURL: imageUrl)
        }

        captionLabel.text = post.caption
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.af.cancelImageRequest()
        profileImageView.af.cancelImageRequest()
        
       
        postImageView.image = nil
        profileImageView.image = UIImage(systemName: "person.circle")
    }
}

extension DateFormatter {
    static let postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
