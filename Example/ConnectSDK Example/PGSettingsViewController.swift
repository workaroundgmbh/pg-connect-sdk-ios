//
//  PGSettingsViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import ConnectSDK
import Foundation
import UIKit

/// ViewController presenting device information and all the available settings after the device is connected.
class PGSettingsViewController: UITableViewController {
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    var centralManager: PGCentralManager?
    private var deviceInformation: PGDeviceInformation?
    private let displaySegueId = "displaySettingsSegue"
    private let configListSegueId = "configListSegue"
    private let feedbackSegueId = "feedbackSegue"
    
    // MARK: - View Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        /// Fetch the device information by creating PGCommand and invoking the requestDeviceInformation.
        let deviceInfoCommand = PGCommand(deviceInfoRequest: PGDeviceInformationRequest(), params: PGCommandParams())
        centralManager?.connectedScanner?.requestDeviceInformation(deviceInfoCommand, completionHandler: { deviceInfo, error in
            if error == nil {
                self.deviceInformation = deviceInfo
                self.serialNumberLabel.text = self.deviceInformation?.serialNumber
                self.firmwareVersionLabel.text = self.deviceInformation?.firmwareRevision
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Gestures methods
    
    @objc
    func backGesture() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case displaySegueId:
            let displaySettingsVC = segue.destination as? PGDiplayViewController
            displaySettingsVC?.centralManager = centralManager
            
        case configListSegueId:
            let listVC = segue.destination as? ConfigurationViewController
            listVC?.setConfigurationManager(configManager: self.centralManager?.configurationManager)
            
        case feedbackSegueId:
            let feedbackVC = segue.destination as? PGWorkerFeedbackViewController
            feedbackVC?.centralManager = centralManager
            
        default:
            break
        }
    }
}
