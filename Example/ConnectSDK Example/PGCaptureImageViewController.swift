//
//  PGCaptureImageViewController.swift
//  ConnectSDK Example
//
//  Copyright © 2023 proglove. All rights reserved.
//

import UIKit
import ConnectSDK

class PGCaptureImageViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var imageQualityTextField: UITextField!
    @IBOutlet weak var triggerTimeoutTextField: UITextField!
    
    var imageManager: PGImageManager?
    var jpegQuality = 20
    var triggerTimeout = 10000
    var imageResoltuion = PGImageResolution.res320_240
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageQualityTextField.text = "\(jpegQuality)"
        imageQualityTextField.returnKeyType = .done
        triggerTimeoutTextField.text = "\(triggerTimeout)"
        triggerTimeoutTextField.returnKeyType = .done
    }
    
    @IBAction func captureImageTapped(_ sender: UIButton) {
        view.resignFirstResponder()
        takeImageButton.isEnabled = false
        takeImage()
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: imageResoltuion = .res320_240
        case 1: imageResoltuion = .res640_480
        case 2: imageResoltuion = .res1280_960
        default: break
        }
        
        print("Image Resolution: \(imageResoltuion)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func imageQualityTextFieldEditChanged(_ sender: UITextField) {
        if let quality = Int(sender.text ?? "") {
            print("Timeout: \(quality)")
            jpegQuality = quality
        }
    }
    
    @IBAction func triggerTimeoutTextFieldEditChanged(_ sender: UITextField) {
        if let timeout = Int(sender.text ?? "") {
            print("Timeout: \(timeout)")
            triggerTimeout = timeout
        }
    }
    
    func takeImage() {
        let captureImageRequest = PGCaptureImageRequest(jpegQuality, resolution: imageResoltuion, timeout: triggerTimeout)
        imageManager?.takeImage(PGCommand(captureImageRequest: captureImageRequest), completionHandler: { [weak self] pgimage, error in
            self?.takeImageButton.isEnabled = true
            
            if let error = error {
                let allertController = UIAlertController(title: "Capture Image Failed", message: "\(error.localizedDescription)", preferredStyle: .alert)
                allertController.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(allertController, animated: true)
            }
            if let pgimage = pgimage {
                let image = UIImage(data: pgimage.imageData)
                self?.capturedImageView.image = image
            }
        })
    }
}
