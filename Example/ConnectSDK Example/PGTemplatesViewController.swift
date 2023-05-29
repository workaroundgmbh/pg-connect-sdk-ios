//
//  PGTemplatesViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import Foundation
import UIKit

/// ViewController presenting the list of all the available templates.
class PGTemplateViewController: UITableViewController {
    // All the available templates
    private let templates: [Template] = Template.allCases
    private var selectedRow = 0
    private var cellIdentifier = "cell"
    var completionHandler: ((Template) -> Void)?
    
    // MARK: - View Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        completionHandler?(templates[self.selectedRow])
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
        cell.textLabel?.text = templates[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        tableView.reloadData()
    }
}
