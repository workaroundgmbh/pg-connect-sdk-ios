//
//  ViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2019 proglove. All rights reserved.
//

import ConnectSDK
import os.log
import UIKit

class ViewController: UIViewController, PGCentralManagerDelegate, PGPeripheralDelegate, PGViewControllerDelegate, PGFirmwareUpdateManagerDelegate, PGConfigurationManagerDelegate {
	let log = OSLog(subsystem: OSLog.appSubsystem, category: "ViewController")
	
	@IBOutlet var qrImageView: UIImageView!
	@IBOutlet var connectionActivityView: UIActivityIndicatorView!
	@IBOutlet var sdkVersionLabel: UILabel!
	var central: PGCentralManager!
	var pgVC: PGViewController?
	var displayedScanner: PGPeripheral?
	var scannedBarcodes: [String] = []
    var firmwareUpdateManager: PGFirmwareUpdateManager?
    var configurationManager: PGConfigurationManager?
	
#if targetEnvironment(simulator)
	let mockBarcodeData = "This data is from a mock".split(separator: " ")
	lazy var mockBarcodeIterator = mockBarcodeData.makeIterator()
	func nextBarcode() -> String {
		var str = self.mockBarcodeIterator.next()
		if str == nil {
			self.mockBarcodeIterator = self.mockBarcodeData.makeIterator()
			str = self.mockBarcodeIterator.next()
		}
		return String(str!)
	}
#endif
    
    // MARK: - View lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sdkVersionLabel.text = "SDK Version: \(ConnectSDKVersionStringObject)"
		// create the central. Restoration can be enabled if desired but after creation the central object must be interrogated to determine the current state of devices
		central = PGCentralManager(delegate: self, enableRestoration: true)
        
        //Set the firmware update manager delegate
        firmwareUpdateManager = central.firmwareUpdateManager
        firmwareUpdateManager?.delegate = self
        
        //Set the configuration manager delegate
        configurationManager = central.configurationManager
        configurationManager?.delegate = self
        
        // Set the cloud insight connection delegate
        central.cloudConnectionDelegate = self
        
		if let m = central.connectedScanner {
			os_log(.info, log: log, "Scanner was already connected when view loaded")
			self.centralManager(central, scannerDidBecomeReady: m)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reset()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showScanner":
            pgVC = segue.destination as? PGViewController
            pgVC?.delegate = self
            pgVC?.configurationManager = self.configurationManager
            pgVC?.centralManager = central
            for b in scannedBarcodes {
                pgVC?.appendBarcode(barcode: b)
            }
        case "configListSegue":
            let listVC = segue.destination as? ConfigurationViewController
            listVC?.setConfigurationManager(configManager: self.configurationManager)
        default:
            break
        }
	}
	
	// MARK: - Connection management

	@IBAction func startNewConnection(_ sender: Any) {
        // start a new connection by generating a QR code for the Scanner to scan through the central. The central then searches for the Scanner that has scanned the QR.
        os_log(.info, log: log, "Starting new connection")
        let s = min(qrImageView.frame.size.width, qrImageView.frame.size.height)
        if let central = central, central.state == .poweredOn {
            // start a new connection by generating a QR code for the Scanner to scan through the central. The central then searches for the Scanner that has scanned the QR.
            let im = central.initiateScannerConnection(withImageSize: CGSize(width: s, height: s))
            qrImageView.image = im
        }
        
        self.connectionActivityView.startAnimating()
        
        // if running in simulator, create a mock to advertise the indicator 2 seconds after scanning starts
#if targetEnvironment(simulator)
        let im = central?.initiateScannerConnection(withImageSize: CGSize(width: s, height: s))
        qrImageView.image = im
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            os_log(.info, log: self.log, "Advertising mock scanner")
            let p = PGMockPeripheral(identifier: UUID().uuidString)
            self.central.add(p)
            p.advertise(withIndicator: self.central.scanningForIndicator!)
        })
#endif
	}
    
    func reset() {
        scannedBarcodes = []
        displayedScanner = nil
        self.connectionActivityView.stopAnimating()
        self.qrImageView.image = nil
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        pgVC = nil
    }
    
    func handleDisconnect(_ scanner: PGPeripheral, error: Error?) {
        if scanner.delegate === self {
            scanner.delegate = nil
        }
        guard scanner == displayedScanner else {
            return
        }
        os_log(.info, log: log, "Scanner disconnected with error %{public}@", String(describing: error))
        scanner.delegate = nil
        
        reset()
        if let error = error {
            let alertController = UIAlertController(title: "Error", message: "Error on \(scanner): \(error)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
	
	// MARK: - Central Delegate
	
	func managerDidUpdateState(_ manager: PGManager) {
		if manager.state != .poweredOn {
			reset()
		}
	}
	
	func centralManager(_ centralManager: PGCentralManager, connectingToScanner scanner: PGPeripheral) {
		// set delegate in connecting method as barcode events may occur when connecting when a central is restoring
		scanner.delegate = self
	}
    
    func centralManager(_ centralManager: PGCentralManager, scannerDidConnect scanner: PGPeripheral) {
        pgVC?.logCount = 1
        os_log(.info, log: log, "Scanner is now connected but still not ready for use.")
    }
    
    func centralManager(_ centralManager: PGCentralManager, didLostConnectionAndReconnectingToScanner scanner: PGPeripheral) {
        os_log(.info, log: log, "Scanner connection is lost. Reconnection is in progress.")
    }
	
	func centralManager(_ centralManager: PGCentralManager, scannerDidBecomeReady scanner: PGPeripheral) {
        let identifier = scanner.identifier
        os_log(.info, log: log, "Scanner with identifier: %@ became ready", identifier)
        
        if displayedScanner != scanner {
            scanner.delegate = self
            displayedScanner = scanner
            self.performSegue(withIdentifier: "showScanner", sender: scanner)
        }
		
		// if mock became ready, send a barcode every 0.5s
#if targetEnvironment(simulator)
		if let p = scanner as? PGMockPeripheral {
			Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {[weak self] t in
				if p.state == .ready {
                    p.sendBarcode((self?.nextBarcode() ?? "" ))
				} else {
					t.invalidate()
				}
			})
		}
#endif
	}
	
    func centralManager(_ centralManager: PGCentralManager, didStartSearchingForIndicator indicator: String?) {
        os_log(.info, log: log, "Searching for indicator: %{public}@", String(describing: indicator))
    }
    
	func centralManager(_ centralManager: PGCentralManager, didFailToConnectToScanner scanner: PGPeripheral, error: Error?) {
		handleDisconnect(scanner, error: error)
	}
	
	func centralManager(_ centralManager: PGCentralManager, didDisconnectFromScanner scanner: PGPeripheral, error: Error?) {
		handleDisconnect(scanner, error: error)
	}
    
    func centralManager(_ centralManager: PGCentralManager, didFailToInitiateConnection error: Error?) {
        os_log(.info, log: log, "Failed to initiate connection with error %{public}@", String(describing: error))
        reset()
    }
    
    // MARK: - PGFirmwareManager delegate
    
    func didStartFirmwareUpdate() {
        os_log(.info, log: log, "Fimware update started.")
    }

    func didChangeFirmwareUpdateProgress(_ percentage: NSInteger) {
        os_log(.info, log: log, "Fimware update progress changed. Current progress:%{public}d%%", percentage)
    }

    func didCompleteFirmwareUpdate() {
        os_log(.info, log: log, "Fimware update completed.")
    }

    func didFailToUpdateFirmwareWithError(_ error: Error?) {
        os_log(.error, log: self.log, "Firmware update failed. Error: %{public}@", error!.localizedDescription)
    }
    
	// MARK: - Peripheral delegate
    
    func peripheral(_ peripheral: PGPeripheral, didScanBarcodeWith data: PGScannedBarcodeResult) {
        var scanResult = data.barcodeContent
        if let symbology = data.barcodeSymbology {
            scanResult.append(" - \(symbology)")
        }
        scannedBarcodes.append(scanResult)
        pgVC?.appendBarcode(barcode: scanResult)
    }
    
    // MARK: - PGConfigurationManager delegate
    
    func peripheral(_ peripheral: PGPeripheral, didSetConfigurationProfile configurationProfile: PGConfigurationProfile) {
        os_log(.info, log: log, "Configuration profile: %{public}@ successfully set", configurationProfile.profileId)
    }
    
    func peripheral(_ peripheral: PGPeripheral?, didFailToSetConfigurationProfile configurationProfile: PGConfigurationProfile?, error: Error?) {
        os_log(.info, log: log, "Failed to set configuration profile with error %{public}@", String(describing: error))
    }
    
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
    
	// MARK: - Scanner view controller delegate
	
	func pgViewControllerDisconnect(pgViewController: PGViewController) {
		guard pgViewController === pgVC else {
			return
		}
		if let m = displayedScanner {
			os_log(.info, log: log, "Disconnecting Scanner")
			central.cancelScannerConnection(m)
		}
		reset()
	}
    
    // MARK: - Double trigger delegate
    func peripheral(_ peripheral: PGPeripheral, didSendButtonTriggerEvent buttonTriggerEvent: PGButtonTriggerEventType) {
        switch buttonTriggerEvent {
        case .doubleTrigger:
            pgVC?.appendBarcode(barcode: "Double trigger activated")
        @unknown default:
            break
        }
    }
    
    func peripheral(_ peripheral: PGPeripheral, didChangeLockState lockState: PGPeripheralLockState, error: Error?) {
        if let error {
            pgVC?.appendBarcode(barcode: "Unlock Error: \(error.localizedDescription)")
            return
        }
        switch lockState {
        case .disabled:
            pgVC?.appendBarcode(barcode: "Scanner locking disabled")
        case .locked:
            pgVC?.appendBarcode(barcode: "Scanner locked")
        case .unlocked:
            pgVC?.appendBarcode(barcode: "Scanner unlocked")
        @unknown default:
            break
        }
    }
    
    func peripheral(_ peripheral: PGPeripheral, didScanAuthenticationBarcodeWith data: PGScannedBarcodeResult, isValid: Bool) {
        if !isValid {
            pgVC?.appendBarcode(barcode: "Scanned invalid barcode, scanner is locked: \(data.barcodeContent) \(data.barcodeSymbology ?? "")")
            return
        }
        pgVC?.appendBarcode(barcode: "Scanned valid barcode, unlocking scanner with \(data.barcodeContent) \(data.barcodeSymbology ?? "")")
    }
}

// MARK: - Cloud Insight Connection Delegate
extension ViewController: PGCloudConnectionDelegate {
    func cloudConnectionStatusDidUpdate(_ status: PGCloudConnectionStatus, error: Error?) {
        os_log(.info, log: log, "Cloud Connection status is: %{public}@", "\(status.rawValue)")
    }
}

