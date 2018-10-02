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
    case SETTINGS = "Settings"
}

class MenuTableViewController: UITableViewController {
    
    var dataTable : [(menuData:MenuData, image:UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named: "iconMenu") {
            dataTable.append((menuData: .HOME, image: image))
            dataTable.append((menuData: .SETTINGS, image: image))
            dataTable.append((menuData: .DISCONNECTION, image: image))
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
        case .SETTINGS:
            // TODO
            print("Settings TO DO")
        }
        
    }
    
    func disconnect() {
        try? Auth.auth().signOut()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signInSingUpViewController = storyBoard.instantiateViewController(withIdentifier: "SignInSingUpViewController") as! SignInSingUpViewController
        self.present(signInSingUpViewController, animated: true)
    }
    
}
