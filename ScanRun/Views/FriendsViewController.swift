//
//  FriendsViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 04/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController{

    @IBOutlet var friendsTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var friends : [User] = []{
        didSet{
            friendsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.tableFooterView = UIView()
        
        getFriends()
    }
    
    func getFriends(){
        NiceActivityIndicatorBuilder().setColor(UIColor.white).build().startAnimating(self.friendsTableView)
        guard let userId = UserManager.shared.userId else { return }
        db.collection("users").document(userId).getDocument { (snap, err) in
            guard let friendsRefs = snap?.get("friends") as? [DocumentReference] else { return }
            for ref in friendsRefs {
                ref.getDocument(completion: { (userSnap, err) in
                    guard let data = userSnap?.data() else { return }
                    self.friends.append(User(json: data))
                    NiceActivityIndicator().stopAnimating(self.friendsTableView)
                })
            }
        }
    }
}

extension FriendsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ClassicCell = tableView.dequeueReusableCell(withIdentifier: "ClassicCell", for: indexPath) as! ClassicCell
        let user = friends[indexPath.row]
        cell.titleLabel?.text = user.username ?? user.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let presenter = self.presentingViewController as? CreateDuelViewController{
            let user = friends[indexPath.row]
            presenter.idFriend = user.id
            presenter.friendName = user.username ?? user.email ?? "l'ami sélectionné"
        }
        self.dismiss(animated: true)
    }
}
