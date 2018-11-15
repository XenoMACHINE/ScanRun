//
//  SearchProductViewController.swift
//  ScanRun
//
//  Created by Alexandre Ménielle on 04/11/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseFirestore

class SearchProductViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsTableview: UITableView!
    
    lazy var db = Firestore.firestore()
    
    var products : [Product] = [] {
        didSet{
            productsTableview.reloadData()
        }
    }
    var searchTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productsTableview.delegate = self
        productsTableview.dataSource = self
        productsTableview.tableFooterView = UIView()
        
        searchBar.delegate = self
    }
    
    func searchProduct(text: String){
        NiceActivityIndicatorBuilder().setColor(.white).build().startAnimating(self.view)
        self.products.removeAll()
        APIManager.shared.getProduct(ean: text) { (data) in
            self.products.append(Product(json: data))
            NiceActivityIndicator().stopAnimating(self.view)
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SearchProductViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ClassicCell = tableView.dequeueReusableCell(withIdentifier: "ClassicCell", for: indexPath) as! ClassicCell
        let name = products[indexPath.row].name ?? ""
        let quantity = products[indexPath.row].quantity ?? ""
        cell.titleLabel.text = "\(name) - \(quantity)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let presenter = presentingViewController as? CreateDuelViewController {
            presenter.chooseProduct =  products[indexPath.row]
        }
        self.dismiss(animated: true)
    }
}


extension SearchProductViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if self.searchTimer?.isValid == true { return } //Anti flood
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            self.searchProduct(text: searchBar.text ?? "")
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
