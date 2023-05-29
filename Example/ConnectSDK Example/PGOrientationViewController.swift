//
//  PGOrientationViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import Foundation
import UIKit

class PGOrientationViewController: UITableViewController {
    private let cellIdentifier = "cell"
    private var selectedRow = 0
    private let orientations = OrientationStrings.allCases
    var completionHandler: ((OrientationStrings) -> Void)?
    
    // MARK: - View Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        completionHandler?(orientations[self.selectedRow])
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orientations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
        cell.textLabel?.text = orientations[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        tableView.reloadData()
    }
}
