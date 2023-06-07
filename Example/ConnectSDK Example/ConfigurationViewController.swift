//
//  ConfigTableViewController.swift
//  ConnectSDK Example
//
//  Created by Nico Adler on 07.12.20.
//  Copyright © 2020 proglove. All rights reserved.
//

import ConnectSDK
import Foundation
import os.log
import UIKit

class ConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    private let log = OSLog(subsystem: OSLog.appSubsystem, category: "ConfigTableViewController")
    private let cellReuseIdentifier = "cell"
    private var configurationManager: PGConfigurationManager?
    private var configProfiles: [PGConfigurationProfile] = []
    private var activeProfile: PGConfigurationProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }

    @objc
    func backGesture() {
        dismiss(animated: true, completion: nil)
    }
    
    func setConfigurationManager(configManager: PGConfigurationManager?) {
        self.configurationManager = configManager
        refreshDataSource()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.configProfiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        let profileId: Swift.String = self.configProfiles[indexPath.row].profileId
        cell.textLabel?.text = profileId

        if profileId == self.activeProfile?.profileId {
            cell.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = UIColor(named: "TableViewCellColor")
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProfile: PGConfigurationProfile = self.configProfiles[indexPath.row]

        os_log(.info, log: self.log, "Selected ProfileId: %{profileId}@", selectedProfile.profileId)

        let command = PGCommand(configurationProfileRequest: selectedProfile)
        self.configurationManager?.changeActiveProfile(command, completionHandler: { error in
            if let error = error {
                os_log(.error, log: self.log, "Active Profile could not be set: %{error}@", error.localizedDescription)
            } else {
                os_log(.info, log: self.log, "Active profile changed to: %{profileId}@", selectedProfile.profileId)
            }

            self.refreshDataSource()
        })
    }

    @IBAction func loadDefaultConfig(_ sender: Any) {
        //Load the sample configuration file.
        if let fileURL = Bundle(for: type(of: self)).url(forResource: "ProGlove", withExtension: "proconfig") {
            configurationManager?.loadConfigurationFile(atPath: fileURL.path) { [weak self] error in
                guard let self = self else {
                    return
                }

                if let error = error {
                    os_log(.error, log: self.log, "Fail to load configuration with error %{public}@", error.localizedDescription)
                } else {
                   os_log(.info, log: self.log, "Configuration File loaded")
                }
                self.refreshDataSource()
            }
        }
    }

    @IBAction func deleteConfig(_ sender: Any) {
        configurationManager?.deleteLoadedConfigurations { [weak self] _ in
            guard let self = self else {
                return
            }

            self.refreshDataSource()
        }
    }

    private func refreshDataSource() {
        self.configurationManager?.getAllConfigurationProfiles { [weak self] (configProfiles: [PGConfigurationProfile]) in
            guard let self = self else {
                return
            }

            self.configProfiles = configProfiles

            self.tableView.reloadData()

            if configProfiles.count == 0 {
                os_log(.error, log: self.log, "Configuration did not contain any profiles.")
                return
            }

            for profile in configProfiles {
                os_log(.info, log: self.log, "ProfileId: %{profileId}@", profile.profileId)
            }
        }

        self.configurationManager?.getActiveConfigurationProfile { [weak self] profile in
            guard let self = self else {
                return
            }
            self.activeProfile = profile

            self.tableView.reloadData()
        }
    }
}
