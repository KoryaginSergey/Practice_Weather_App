//
//  SearchListViewController.swift
//  Practice_Weather_App
//
//  Created by Admin on 21.07.2021.
//

import UIKit

class SearchListViewController: UIViewController {
    
 
//    @IBOutlet weak var searchBar: UISearchBar!
//
//
//    private var pendingRequestWorkItem: DispatchWorkItem?
    var cities = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.isEditing = true

//        searchBar.delegate = self
        cities = ["Kyiv", "Kharkov", "lvov", "City2", "City5", "City10"]
        
        
        
    }
   

}

extension SearchListViewController: UITableViewDataSource {
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as! SearchListCell
        cell.setParamsViewForCell()
        
        let city = cities[indexPath.row]
        cell.nameCityLabel.text = city
        
        return cell
    }
    
    
}
