//
//  FeedViewController.swift
//  BeRealClone
//
//  Created by Rista Subedi on 2/02/26.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapLogOutButton(_ sender: Any) {
        User.logout { [weak self] result in

            switch result {
            case .success:

                DispatchQueue.main.async {

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "loginNav") as! UINavigationController
                    navigationController.viewControllers = [storyboard.instantiateViewController(withIdentifier: "LoginViewController")]

                    navigationController.modalPresentationStyle = .fullScreen
                    self?.present(navigationController, animated: true, completion: nil)
                    self?.navigationController?.setViewControllers([], animated: false)
                }
            case .failure(let error):
                print("❌ Log out error: \(error)")
            }
        }

    }
    
    private var posts = [Post]() {
        didSet {            tableView.reloadData()
        }
    }
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.tableView.rowHeight = 400;
        self.navigationItem.hidesBackButton = true
        
        
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshFeed(send: UIRefreshControl) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }
    
    private func queryPosts() {
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        query.find { [weak self] result in
            switch result {
            case .success(let posts):                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
