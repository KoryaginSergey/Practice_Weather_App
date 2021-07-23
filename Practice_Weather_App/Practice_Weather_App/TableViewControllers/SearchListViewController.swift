//
//  SearchListViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 21.07.2021.
//

import UIKit


class SearchListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchListImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    

    private let searchListCellID = String(describing: SearchListCell.self)
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var dataTask: URLSessionDataTask?
    var cities: [CityModel] = [CityModel]()
    
    var favoriteCities: [CityModel] = [CityModel(name: "Kharkiv", lat: 50.0, lon: 49.0)]

    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.isEditing = true
        self.tableView.keyboardDismissMode = .onDrag

        searchBar.delegate = self
        cities = favoriteCities
        configureNavigationButtons()
        
    }
    
}

// MARK: - Extensions

extension SearchListViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchListCellID, for: indexPath) as! SearchListCell
        cell.setParamsViewForCell()
        
        let city = cities[indexPath.row]
        cell.nameCityLabel.text = city.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removeElement = cities[sourceIndexPath.row]
        cities.remove(at: sourceIndexPath.row)
        cities.insert(removeElement, at: destinationIndexPath.row)
        print(cities[destinationIndexPath.row])
        print(destinationIndexPath.row)
    }
}

extension SearchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = tableViewDidDeleteRow(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func tableViewDidDeleteRow(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in

            self.cities.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            completion(true)
        }
        action.backgroundColor = .systemRed
        return action
    }
    
}

extension SearchListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingRequestWorkItem?.cancel()

        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.invokeNetworkingRequest(text: searchText)
        }

        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                    execute: requestWorkItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

private extension SearchListViewController {
    
    private func configureNavigationButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(cancelButtonSelector))
    }
    
    @objc private func cancelButtonSelector() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    private func invokeNetworkingRequest(text: String) {
        self.dataTask?.suspend()
        self.dataTask = Networkmanager.shared.getListOfCities(by: text) { [weak self] cityModels in
            if let  cities = cityModels {
                self?.cities = cities
                self?.tableView.reloadData()
            }
        }
    }
    
}

