//
//  ProductDetailViewController.swift
//  ShopSearchExampleApp
//
//  Created by Ricardo Koch on 4/7/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit
import ShopSearch

class ProductDetailViewController: UITableViewController {

	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var linkLabel: UILabel!
	@IBOutlet weak var vendorsLabel: UILabel!
	
	var product: GoogleProduct!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		titleLabel.text = self.product.title
		categoryLabel.text = self.product.category?.name
		linkLabel.text = self.product.googleLinkUrl
		
		var bestPrice: Int?
		for vendor in self.product.vendors {
			if let basePrice = vendor.basePrice?.intValue, bestPrice == nil || basePrice < bestPrice! {
				bestPrice = basePrice
			}
		}
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		vendorsLabel.text = formatter.string(from: NSNumber(value: bestPrice ?? 0))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source



    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
