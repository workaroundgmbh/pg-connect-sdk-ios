//
//  PGRefreshTypeViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import ConnectSDK
import Foundation
import UIKit

/// ViewController containing the list of all the available RefreshTypes.
class PGRefreshViewController: UITableViewController {
    // The list of all the available refresh types.
    private var refreshTypes = RefreshTypeStrings.allCases
    private var selectedRow = 0
    private var cellIdentifier = "cell"
    var completionHandler: ((RefreshTypeStrings) -> Void)?
    
    // MARK: - View Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        completionHandler?(refreshTypes[selectedRow])
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refreshTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
        cell.textLabel?.text = refreshTypes[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        tableView.reloadData()
    }
}
