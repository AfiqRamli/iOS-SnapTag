//
//  TabBarVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 02/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//


import UIKit

class TabBarVC: UITabBarController{

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    //MARK: - Delegate Methods
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let title = item.title {
            print("Selecting tab \(title)")
        }
    }
    
    //MARK: - Private Methods
    func configureTabBar() {
        // Create Tab One
        let tabOne = CurrentLocationVC.instance()
        tabOne.tabBarItem.title = "Tag"
        tabOne.tabBarItem.image = UIImage(named: "earth-usa")
        
        // Create Tab Two
        let storyboard = UIStoryboard(name: "LocationsVC", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LocationsID") as! LocationsVC
        let tabTwo = UINavigationController(rootViewController: vc)
        
        tabTwo.tabBarItem.title = "Locations"
        tabTwo.tabBarItem.image = UIImage(named: "briefcase")
        
        
        //Create Tab three
        let tabThree = ThirdVC.instance()
        tabThree.tabBarItem.title = "Storage"
        tabThree.tabBarItem.image = UIImage(named: "cloud")
        
        let controllers = [tabOne, tabTwo, tabThree]
        self.viewControllers = controllers
    }
    
}







