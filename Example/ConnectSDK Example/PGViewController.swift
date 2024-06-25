//
//  PGViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2019 proglove. All rights reserved.
//

import ConnectSDK
import os.log
import UIKit

protocol PGViewControllerDelegate: AnyObject {
    func pgViewControllerDisconnect(pgViewController: PGViewController)
}

/// ViewController responsible for presenting the scanned barcodes. Also contains the segue to Settings page.
class PGViewController: UIViewController {
    @IBOutlet private var barcodeTextView: UITextView!
    @IBOutlet weak var progressView: PGProgressView!
    @IBOutlet weak var insightConnectionStatus: UILabel!
    weak var delegate: PGViewControllerDelegate?
    var centralManager: PGCentralManager?
    var configurationManager: PGConfigurationManager?
    var firmwareUpdateManager: PGFirmwareUpdateManager?
    var imageManager: PGImageManager?
    var settingsSegue = "settingsSegue"
    var logCount = 1
    private var barcodes: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurationManager?.delegate = self
        barcodes = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for b in barcodes {
            appendBarcodeToTextView(barcode: b)
        }
        firmwareUpdateManager = centralManager?.firmwareUpdateManager
        firmwareUpdateManager?.delegate = self
        
        imageManager = centralManager?.imageManager
        
        if let central = centralManager, central.connectedToCloud {
            updateInsightConnectionLabel(.connected)
        }
        centralManager?.cloudConnectionDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case settingsSegue:
            let navigationVC = segue.destination as? UINavigationController
            let settingsVC = navigationVC?.viewControllers.first as? PGSettingsViewController
            settingsVC?.centralManager = centralManager
        default:
            break
        }
    }
    
    @IBAction func disconnect(_ sender: Any) {
        delegate?.pgViewControllerDisconnect(pgViewController: self)
    }
        
    func appendBarcode(barcode: String) {
        barcodes.append(barcode)
        if isViewLoaded {
            appendBarcodeToTextView(barcode: barcode)
        }
    }
    
    private func appendBarcodeToTextView(barcode: String) {
        barcodeTextView.text = "\(barcode) (\(logCount))\n\(barcodeTextView.text ?? "")"
        logCount += 1
    }
}

extension PGViewController: PGFirmwareUpdateManagerDelegate {
    func didStartFirmwareUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.showProgress()
        }
    }
    
    func didChangeFirmwareUpdateProgress(_ percentage: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.updateProgress(percentage)
        }
    }
    
    func didCompleteFirmwareUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.isHidden = true
        }
    }
    
    func didFailToUpdateFirmwareWithError(_ error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.progressView.isHidden = true
        }
    }
    
    func updateInsightConnectionLabel(_ status: PGCloudConnectionStatus) {
        var textStatus = ""
        switch status {
        case .connected:
            textStatus = "Insight connected"
        case .disconnected:
            textStatus = "Insight disconnected"
        case .connecting:
            textStatus = "Connecting to Insight..."
        case .error:
            textStatus = "Error connecting to Insight. Try again."
        @unknown default:
            textStatus = ""
        }
        DispatchQueue.main.async { [weak self] in
            self?.insightConnectionStatus.text = textStatus
        }
    }
}

// MARK: - PGCloudConnectionDelegate
extension PGViewController: PGCloudConnectionDelegate {
    func cloudConnectionStatusDidUpdate(_ status: PGCloudConnectionStatus, error: Error?) {
        updateInsightConnectionLabel(status)
    }
}

// MARK: - PGConfigurationManager delegate
extension PGViewController: PGConfigurationManagerDelegate {
    func peripheral(_ peripheral: PGPeripheral, didSetConfigurationProfile configurationProfile: PGConfigurationProfile) {}
    
    func peripheral(_ peripheral: PGPeripheral?, didFailToSetConfigurationProfile profile: PGConfigurationProfile?, error: Error?) {}
    
    func didLoadNewConfiguration(_ configurationId: String) {
        let allertController = UIAlertController(title: "Configuration", message: "Successfully Loaded New Configuration with ID \(configurationId)", preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(allertController, animated: true)
    }
    
    func didFailToLoadNewConfiguration(_ error: Error) {
        let allertController = UIAlertController(title: "Configuration", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(allertController, animated: true)
    }
}
