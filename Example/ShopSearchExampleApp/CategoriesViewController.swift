//
//  CategoriesViewController.swift
//  ShopSearchExampleApp
//
//  Created by Ricardo Koch on 4/7/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit
import ShopSearch

class CategoriesViewController: UITableViewController {

    var categories: [GoogleCategory]?
	var selectedCategory: GoogleCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if self.categories == nil {
			self.categories = ShopSearch.shared().getSortedCategories()
		}
		self.title = "Categories"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryReuseIdentifier", for: indexPath)

        let category = self.categories?[indexPath.row]
        cell.textLabel?.text = category?.name

        return cell
    }
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		selectedCategory = self.categories?[indexPath.row]
		return indexPath
	}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "showCategory", let cont = segue.destination as? CategoriesViewController {
			cont.categories = self.selectedCategory?.children
		}
    }


}
