//
//  SearchListTableViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 21.07.2021.
//

import UIKit

class SearchListTableViewController: UITableViewController {
    
 
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    var cities = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.isEditing = true

        searchBar.delegate = self
        cities = ["Kyiv", "Kharkov", "lvov", "City2", "City5", "City10"]
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as! SearchListCell
        cell.setParamsViewForCell()
        
        let city = cities[indexPath.row]
        cell.nameCityLabel.text = city
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = tableViewDidDeleteRow(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removeElement = cities[sourceIndexPath.row]
        cities.remove(at: sourceIndexPath.row)
        cities.insert(removeElement, at: destinationIndexPath.row)
        print(cities[destinationIndexPath.row])
        print(destinationIndexPath.row)
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
    
    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return
//    }

}
      // MARK: - Extensions

extension SearchListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Cancel the currently pending item
            pendingRequestWorkItem?.cancel()

            // Wrap our request in a work item
            let requestWorkItem = DispatchWorkItem { [weak self] in
                print(searchText)
            }

            // Save the new work item and execute it after 2 s
            pendingRequestWorkItem = requestWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2,
                                          execute: requestWorkItem)
        }
    
}

