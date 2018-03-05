//
//  UIViewController+Instantiate.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 02/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    class func instance() -> Self {
        let storyboardName = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.initialViewController()
    }
    
}

extension UIStoryboard {
    func initialViewController<T: UIViewController>() -> T {
        return self.instantiateInitialViewController() as! T
    }
}
