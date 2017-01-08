//
//  SearchResultsViewController.swift
//  ShopSearchExampleApp
//
//  Created by Ricardo Koch on 4/8/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit
import ShopSearch

class SearchResultsViewController: UITableViewController {

    var results:[GoogleProduct]?
	var selectedProduct: GoogleProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsReuseIdentifier", for: indexPath)
        
        let category = self.results?[indexPath.row]
        cell.textLabel?.text = category?.title
        
        return cell
    }

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		selectedProduct = self.results?[indexPath.row]
		return indexPath
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowProduct", let cont = segue.destination as? ProductDetailViewController {
			cont.product = selectedProduct
		}
    }
	

}
