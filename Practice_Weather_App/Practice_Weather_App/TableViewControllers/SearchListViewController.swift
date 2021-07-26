//
//  SearchListViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 21.07.2021.
//

import UIKit
import CoreData


class SearchListViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchListImageView: UIImageView!
    @IBOutlet weak private var searchBar: UISearchBar!
    
    private let searchListCellID = String(describing: SearchListCell.self)
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var dataTask: URLSessionDataTask?
    
    private var models = [CDCityModel]()
    
    private var cities = [CityModel]()
    
    private var isSearching = false
    private var buttonIsEdit = false
    private let nameNavigationItem = "Favorites list"
    private let heightForRow: CGFloat = 60
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        configureNavigationButtons()
        
        self.navigationItem.title = nameNavigationItem
        self.fetchData()
    }
}

// MARK: - Extensions

extension SearchListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.cities.count
        } else {
            return self.models.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchListCellID, for: indexPath) as! SearchListCell
        cell.setParamsViewForCell()
        if isSearching {
            let city = cities[indexPath.row]
            cell.nameCityLabel.text = city.name
        } else {
            let city = models[indexPath.row]
            cell.nameCityLabel.text = city.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removeElement = models[sourceIndexPath.row]
        models.remove(at: sourceIndexPath.row)
        models.insert(removeElement, at: destinationIndexPath.row)
    }
}

extension SearchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = tableViewDidDeleteRow(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func tableViewDidDeleteRow(indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            let model = self.models.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.deleteCDCityModel(model: model)
            
            completion(true)
        }
        
        action.backgroundColor = .systemRed
        return action
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            self.saveItemToDataBase(indexPath: indexPath)
            isSearching = false
            searchBar.resignFirstResponder()
            searchBar.text = ""
            fetchData()
            self.tableView.reloadData()
        } else {
//            self.saveItemToDataBase(indexPath: indexPath)
            searchBar.text = ""
            fetchData()
            self.tableView.reloadData()
        }
    }
}

extension SearchListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
        } else {
            isSearching = true
            pendingRequestWorkItem?.cancel()
            let requestWorkItem = DispatchWorkItem { [weak self] in
                self?.invokeNetworkingRequest(text: searchText)
            }
            pendingRequestWorkItem = requestWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2,
                                          execute: requestWorkItem)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
        searchBar.text = ""
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
    }
}

private extension SearchListViewController {
    
    private func configureNavigationButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(cancelButtonSelector))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonSelector))
    }
    
    @objc private func cancelButtonSelector() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonSelector() {
        if isSearching == false {
            if buttonIsEdit {
                searchBar.isHidden = false
                self.tableView.isEditing = false
                buttonIsEdit = false
            } else {
                searchBar.isHidden = true
                self.tableView.isEditing = true
                buttonIsEdit = true
            }
        }
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
    
    private func fetchData() {
        let context = DataModels.sharedInstance.context
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: "CDCityModel")
        do {
            return self.models = try context.fetch(fetchRequest)
        } catch {
            print("ERROR")
        }
        self.tableView.reloadData()
    }
    
    private func deleteCDCityModel(model: CDCityModel?) {
        let context = DataModels.sharedInstance.context
        guard let model = model else {
            return
        }
        context.delete(model)
        DataModels.sharedInstance.saveContext()
    }
    
    private func saveItemToDataBase(indexPath: IndexPath) {
        let city = cities[indexPath.row]
        let context = DataModels.sharedInstance.context
        let entity = NSEntityDescription.entity(forEntityName: "CDCityModel", in: context)!
        let model = CDCityModel(entity: entity, insertInto: context)
        
        model.name = city.name
        model.latitude = city.lat!
        model.longitude = city.lon!
        
        DataModels.sharedInstance.saveContext()
    }
    
    
}
