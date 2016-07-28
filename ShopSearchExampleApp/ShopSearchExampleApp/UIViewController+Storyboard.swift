//
//  UIViewController+Storyboard.swift
//  ShopSearchExampleApp
//
//  Created by Ricardo Koch on 4/9/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit

extension UIViewController {

    func instantiateViewController<T>(_ sbIdentifier:String) -> T? {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        return sb.instantiateViewController(withIdentifier: sbIdentifier) as? T
    }
    

}
