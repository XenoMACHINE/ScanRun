//
//  ScoresViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 01/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ScoresViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var users : [User] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top 100"
        
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        getUsers()
    }
    
    func getUsers(){
        NiceActivityIndicator().startAnimating(self.tableView)
        db.collection("users").order(by: "score", descending: false).limit(to: 100).getDocuments { (snap, err) in
            let usersSnap = snap?.documents ?? []
            self.users = usersSnap.map({ User(json: $0.data()) })
            NiceActivityIndicator().stopAnimating(self.tableView)
        }
    }

}

extension ScoresViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ScoreCell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell") as! ScoreCell
        
        let user = users[indexPath.row]
        cell.usernameLabel.text = user.username ?? user.email
        cell.scoreLabel.text = "\(user.score)"
        
        return cell
    }
}
