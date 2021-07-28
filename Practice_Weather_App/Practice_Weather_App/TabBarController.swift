//
//  TabBarController.swift
//  Practice_Weather_App
//
//  Created by Admin on 28.07.2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.tabBar.isTranslucent = false
//        self.tabBar.backgroundColor = UIColor.white
//        let image = UIImage()
//        image.colo

//        self.tabBar.tintAdjustmentMode = .normal
        
        if let items = self.tabBar.items {
            for (index, item) in items.enumerated() {
                item.image = self.getImage(by: index)
                let appearance = UITabBarAppearance()
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 180.0/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1.0)
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 95.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 180.0/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1.0), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .semibold)]
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 95.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0, weight: .semibold)]
                
                item.standardAppearance = appearance
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.backgroundColor = UIColor.white

    }
}

extension TabBarController {
    func getImage(by index: Int) -> UIImage? {
        switch index {
        case 0:
            return UIImage(named: "home")
        case 1:
            return UIImage(named: "grid")
        default:
            return nil
        }
    }
}
