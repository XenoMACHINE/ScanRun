//
//  MenuTableViewController.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 02/10/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseAuth

enum MenuData : String {
    case HOME = "Home"
    case DISCONNECTION = "Disconnection"
    case PROFILE = "Profile"
}

class MenuTableViewController: UITableViewController {
    
    var dataTable : [(menuData:MenuData, image:UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        
        if let iconHome = UIImage(named: "iconHome"),
            let iconUser = UIImage(named: "user"),
            let iconDisconnection = UIImage(named: "iconDisconnection") {
            
            dataTable.append((menuData: .HOME, image: iconHome))
            dataTable.append((menuData: .PROFILE, image: iconUser))
            dataTable.append((menuData: .DISCONNECTION, image: iconDisconnection))
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTable.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as? MenuTableViewCell else { return UITableViewCell() }
        
        cell.setup(data: dataTable[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        
        dismiss(animated: true)
        
        switch dataTable[indexPath.row].menuData {
            
        case .HOME:
            break
        case .DISCONNECTION:
            disconnect()
        case .PROFILE:
            // TODO
            print("Profile TO DO")
        }
        
    }
    
    func disconnect() {
        try? Auth.auth().signOut()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signInSingUpViewController = storyBoard.instantiateViewController(withIdentifier: "SignInSingUpViewController") as! SignInSingUpViewController
        self.present(signInSingUpViewController, animated: true)
    }
    
}
