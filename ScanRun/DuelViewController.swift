//
//  DuelViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 06/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DuelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var db = Firestore.firestore()
    var friends : [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        NiceActivityIndicatorBuilder()
            .setSize(50)
            .setType(.ballPulse)
            .build()
            .startAnimating(self.tableView)
        
        if let id = UserManager.shared.userId {
            db.collection("users").document(id).getDocument() { (querySnapshot, err) in
                self.friends.removeAll()
                for friendId in querySnapshot?.data()?["friends"] as? [String] ?? []{
                    self.db.collection("users").document(friendId).getDocument(completion: { (friendSnap, err) in
                        if let id = friendSnap?.data()?["id"] as? String,
                            let email = friendSnap?.data()?["email"] as? String{
                            
                            self.friends.append(User(id: id, email: email))
                            self.tableView.reloadData()
                            NiceActivityIndicator().stopAnimating(self.tableView)
                        }
                    })
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DuelViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : FriendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        
        cell.nameLabel.text = friends[indexPath.row].email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let friend = friends[indexPath.row]
        tableView.reloadData()
        self.dismiss(animated: true)
    }
}
