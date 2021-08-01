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
    
    var completion: (() -> ())?
    
    private let searchListCellID = String(describing: SearchListCell.self)
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var dataTask: URLSessionDataTask?
    private let backgroundImageView = UIImageView()
    
    
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
        self.setBackgroundImage()
        self.fetchData()
    }
}

// MARK: - TableViewDataSource

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
            cell.nameCountryLabel.text = city.country
        } else {
            let city = models[indexPath.row]
            cell.nameCityLabel.text = city.name
            cell.nameCountryLabel.text = city.country
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
        self.reloadDataModelIndexes()
    }
}

// MARK: - TableViewDelegate

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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSearching
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            self.saveItemToDataBase(indexPath: indexPath)
            isSearching = false
            searchBar.resignFirstResponder()
            searchBar.text = ""
            fetchData()
            cities.removeAll()
            self.tableView.reloadData()
        } else {
            searchBar.text = ""
            fetchData()
            self.tableView.reloadData()
        }
    }
}

// MARK: - SearchBarDelegate

extension SearchListViewController: UISearchBarDelegate {
    
    func reloadDataModelIndexes() {
        for (index, element) in self.models.reversed().enumerated() {
            element.id = Int16(index)
        }
        DataModels.sharedInstance.saveContext()
        self.completion?()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            isSearching = false
            cities.removeAll()
            tableView.reloadData()
        } else {
            isSearching = true
            tableView.reloadData()
            pendingRequestWorkItem?.cancel()
            let requestWorkItem = DispatchWorkItem { [weak self] in
                self?.invokeNetworkingRequest(text: searchText)
            }
            pendingRequestWorkItem = requestWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
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
        searchBar.text = ""
        self.tableView.reloadData()
    }
}

// MARK: - Private extensions

private extension SearchListViewController {
    
    private func setBackgroundImage() {
        backgroundImageView.contentMode = .scaleAspectFill

        backgroundImageView.frame = view.bounds
        backgroundImageView.image = UIImage(named: "Mountain")
        view.insertSubview(backgroundImageView, at: 0)
    }
    
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
                searchBar.resignFirstResponder()
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
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        let fetchRequest = NSFetchRequest<CDCityModel>(entityName: "CDCityModel")
        fetchRequest.sortDescriptors = [sortDescriptor]
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
        self.completion?()
    }
    
    private func saveItemToDataBase(indexPath: IndexPath) {
        let city = cities[indexPath.row]
        
        if let cityObject = CDCityModel.getCity(by: city.name) {
            cityObject.name = city.name
            cityObject.id = Int16(CDCityModel.objectNumber())
            cityObject.country = city.country
        } else {
            let newCityObject = CDCityModel.createObject() as CDCityModel
            newCityObject.name = city.name
            newCityObject.id = Int16(CDCityModel.objectNumber())
            newCityObject.country = city.country
        }

        DataModels.sharedInstance.saveContext()
        self.completion?()
    }
    
}
