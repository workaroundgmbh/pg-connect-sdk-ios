//
//  PGLogViewController.swift
//  ConnectSDK Example
//
//  Created by Bozidar Jevic on 19/07/2021.
//  Copyright © 2021 proglove. All rights reserved.
//

import UIKit

class PGLogViewController: UITableViewController {
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row, indexPath.section) {
        case (0, 0):
            exportLogs()
        case (0, 1):
            deleteLogs()
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private convenience methods
    
    private func exportLogs() {
        guard let logFile = logger.logFileUrl else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: ["Share logs", logFile], applicationActivities: nil)
        
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
        }
        
        present(activityViewController, animated: true, completion: nil )
    }
    
    private func deleteLogs() {
        logger.deleteLogs()
    }
}
