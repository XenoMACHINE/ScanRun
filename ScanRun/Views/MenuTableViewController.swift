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
    case HOME = "Accueil"
    case DISCONNECTION = "Déconnexion"
    case PROFILE = "Profile"
    case DUELS = "Mes duels"
    case SCORES = "Classement"
}

class MenuTableViewController: UITableViewController {
    
    var dataTable : [(menuData:MenuData, image:UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        
        if let iconHome = UIImage(named: "iconHome"),
            let iconUser = UIImage(named: "user"),
            let iconDuel = UIImage(named: "duel"),
            let iconScore = UIImage(named: "score"),
            let iconDisconnection = UIImage(named: "iconDisconnection") {
            
            dataTable.append((menuData: .HOME, image: iconHome))
            dataTable.append((menuData: .PROFILE, image: iconUser))
            dataTable.append((menuData: .DUELS, image: iconDuel))
            dataTable.append((menuData: .SCORES, image: iconScore))
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
        
        
        switch dataTable[indexPath.row].menuData {
            
        case .HOME:
            dismiss(animated: true)
        case .DISCONNECTION:
            disconnect()
        case .PROFILE:
            goToProfile()
        case .DUELS:
            goToDuels()
        case .SCORES:
            goToScores()
        }
    }
    
    func goToScores(){
        self.dismiss(animated: true) {
            guard let topController = UIApplication.topViewController() else { return }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "ScoresViewController") as! ScoresViewController
            topController.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func goToDuels(){
        self.dismiss(animated: true) {
            guard let topController = UIApplication.topViewController() else { return }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "MyDuelsViewController") as! MyDuelsViewController
            topController.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func goToProfile(){
        self.dismiss(animated: true) {
            guard let topController = UIApplication.topViewController() else { return }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            topController.present(controller, animated: true)
        }
    }
    
    func disconnect() {
        self.dismiss(animated: true) {
            guard let topController = UIApplication.topViewController() else { return }
            try? Auth.auth().signOut()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "SignInSingUpViewController") as! SignInSingUpViewController
            topController.present(controller, animated: true)
        }
    }
    
}
