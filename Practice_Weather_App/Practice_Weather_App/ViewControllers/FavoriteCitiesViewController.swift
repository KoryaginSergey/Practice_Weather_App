//
//  FavoriteCitiesViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import UIKit

class FavoriteCitiesViewController: UIPageViewController {
    
    var weatherVcs = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationButtons()
        
        if weatherVcs.count > 0 {
            self.dataSource = self
            self.setViewControllers([weatherVcs[0]], direction: .forward, animated: false, completion: nil)
        }
    }

}

extension FavoriteCitiesViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.weatherVcs.firstIndex(of: viewController) {
            if index < weatherVcs.count - 1 {
                return weatherVcs[index + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.weatherVcs.firstIndex(of: viewController) {
            if index > 0 {
                return weatherVcs[index - 1]
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.weatherVcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVc = pageViewController.viewControllers?[0] else {
            return 0
        }
        return self.weatherVcs.firstIndex(of: currentVc) ?? 0
    }
    
}

private extension FavoriteCitiesViewController {
    
    private func configureNavigationButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonSelector))
    }
    
    @objc private func addButtonSelector() {
        let storyboard = UIStoryboard(name: String(describing: SearchListViewController.self), bundle: nil)
        let searchVc = storyboard.instantiateViewController(identifier: String(describing: SearchListViewController.self)) as SearchListViewController
        let navigation = UINavigationController(rootViewController: searchVc)
        navigation.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigation, animated: true, completion: nil)
    }

}
