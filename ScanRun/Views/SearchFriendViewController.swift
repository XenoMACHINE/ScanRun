//
//  SearchFriendViewController.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 15/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseFirestore

class SearchFriendViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    
    var friends : [User] = [] {
        didSet{
            friendsTableView.reloadData()
        }
    }
    var searchTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.tableFooterView = UIView()
        
        searchBar.delegate = self
    }
    
    func searchFriend(text: String){
        NiceActivityIndicatorBuilder().setColor(.white).build().startAnimating(self.view)
        
        db.collection("users")
            .whereField("username", isEqualTo: text)
            .getDocuments { (snapshot, error) in
                guard let data = snapshot?.documents else { return }
                self.friends = data.map({ User(json: $0.data()) })
                NiceActivityIndicator().stopAnimating(self.view)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SearchFriendViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ClassicCell = tableView.dequeueReusableCell(withIdentifier: "ClassicCell", for: indexPath) as! ClassicCell
        let name = friends[indexPath.row].username ?? ""
        cell.titleLabel.text = "\(name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.friends[indexPath.row]
        guard let userId = UserManager.shared.userId,
               let friendId = user.id else { return }
        let friendRef = db.collection("users").document(friendId)
        db.collection("users").document(userId).updateData(["friends":FieldValue.arrayUnion([friendRef])])
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SearchFriendViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if self.searchTimer?.isValid == true { return } //Anti flood
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            self.searchFriend(text: searchBar.text ?? "")
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
