//
//  MyDuelsViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 05/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyDuelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var myDuels : [Duel] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var productByDuelId: [String:Product] = [:] {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        self.title = "MES DUELS"
        
        getMyDuels()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func getMyDuels(){
        guard let idUser = UserManager.shared.userId else { return }
        NiceActivityIndicatorBuilder().setColor(.white).build().startAnimating(self.view)
        db.collection("users").document(idUser).getDocument { (snap, err) in
            guard let duels = snap?.get("duels") as? [DocumentReference] else { return }
            for ref in duels{
                ref.getDocument(completion: { (snap, err) in
                    guard let data = snap?.data() else { return }
                    let duel = Duel(json: data)
                    self.myDuels.append(duel)
                    self.getProduct(duel.idProduct, duelId: duel.id)
                    NiceActivityIndicator().stopAnimating(self.view)
                })
            }
            
        }
    }
    
    func getProduct(_ productId : String?, duelId: String?){
        guard let idProduct = productId, let idDuel = duelId else { return }
        db.collection("products").document(idProduct).getDocument { (snap, err) in
            guard let data = snap?.data() else { return }
            self.productByDuelId[idDuel] = Product(json: data)
        }
    }
}

extension MyDuelsViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDuels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MyDuelCell = tableView.dequeueReusableCell(withIdentifier: "MyDuelCell", for: indexPath) as! MyDuelCell
        let duel = myDuels[indexPath.row]
        
        cell.titleLabel.text = duel.title
        cell.subTitleLabel.text = "" //product vrand
        
        if let product = productByDuelId[duel.id ?? ""]{
            cell.titleLabel.text = product.name
            cell.subTitleLabel.text = product.brand
            cell.setImage(imageUrl: product.imageUrl)
        }
        
        if duel.succeed {
            cell.timeLeftLabel.text = "REUSSI"
            cell.tag = 1
            return cell
        }
    
        if let endDate = duel.endDate?.dateValue(){
            let calendar = Calendar.current
            let timeLeft = calendar.dateComponents([.day,.hour,.minute,.second], from: Date(), to: endDate)
            
            let strDays = (timeLeft.day ?? 0) > 0 ? "\((timeLeft.day ?? 0))j " : ""
            let strHours = (timeLeft.hour ?? 0) > 0 ? "\((timeLeft.hour ?? 0))h " : ""
            let strMinutes = (timeLeft.minute ?? 0) > 0 ? "\((timeLeft.minute ?? 0))min " : ""
            let strSeconds = (timeLeft.second ?? 0) > 0 ? "\((timeLeft.second ?? 0))s " : ""
            
            cell.timeLeftLabel.text = strDays + strHours + strMinutes + strSeconds
            if cell.timeLeftLabel.text == "" {
                cell.timeLeftLabel.text = "FINI"
                cell.tag = 1
            }
        }else{
            cell.timeLeftLabel.text = "EN ATTENTE"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as? MyDuelCell
        guard cell?.tag == 0 else { return }
        
        let duel = myDuels[indexPath.row]
        if let product = productByDuelId[duel.id ?? ""]{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "CheckDuelViewController") as! CheckDuelViewController
            
            product.loadedImage = cell?.imageDuel.image
            
            controller.product = product
            controller.duel = duel
            self.navigationController?.pushViewController(controller, animated: true)

        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
}
