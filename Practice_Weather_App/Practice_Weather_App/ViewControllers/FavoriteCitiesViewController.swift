//
//  FavoriteCitiesViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 20.07.2021.
//

import UIKit
import CoreData

class FavoriteCitiesViewController: UIPageViewController {
    
    private var weatherVcs = [UIViewController]()
    private var defaultWeatherVcs = [UIViewController]()
    
    private var models = [CDCityModel]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        self.fetchData()
        self.dataSource = self
        weatherVcs = createArrayVC()
        if weatherVcs.count > 0 {
            self.setViewControllers([weatherVcs[0]], direction: .forward, animated: false, completion: nil)
        } else {
            defaultWeatherVcs = createDefaultArrayVC()
            self.setViewControllers([defaultWeatherVcs[0]], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add your favorite cities --->>"
        self.configureNavigationButtons()
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
        if weatherVcs.count > 0 {
            return self.weatherVcs.count
        } else {
            return 1
        }
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
    
    private func fetchData() {
        let context = DataModels.sharedInstance.context
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: "CDCityModel")
        do {
            self.models = try context.fetch(fetchRequest)
        } catch {
            print("ERROR")
        }
    }
    
    private func createArrayVC() -> [UIViewController] {
        var weatherVcsArray = [UIViewController]()
        
        for model in models {
            guard let modelVC =
                    storyboard?.instantiateViewController(identifier: String(describing: CurrentLocationViewController.self))
                    as? CurrentLocationViewController else {continue}
            weatherVcsArray.append(modelVC)
        }
        return weatherVcsArray
    }
    
    private func createDefaultArrayVC() -> [UIViewController] {
        var weatherVcsArray = [UIViewController]()
        guard let modelVC =
                storyboard?.instantiateViewController(identifier: String(describing: CurrentLocationViewController.self))
                as? CurrentLocationViewController else {return weatherVcsArray}
        weatherVcsArray.append(modelVC)
        return weatherVcsArray
    }
}

