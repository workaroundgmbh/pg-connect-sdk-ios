//
//  PGFirmwareUpdateProgressViewController.swift
//  ConnectSDK Example
//
//  Created by Vlastimir Radojevic on 3/13/23.
//  Copyright © 2023 proglove. All rights reserved.
//

import UIKit

class PGProgressView: UIStackView {
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = .lightGray
        progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return progressView
    }()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.isHidden = true
        addProgressView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addProgressView()
    }
    
    private func addProgressView() {
        let uiLabel = UILabel()
        uiLabel.text = "Firmware Update"
        
        self.addArrangedSubview(uiLabel)
        self.addArrangedSubview(progressView)
        self.alignment = .center
        self.spacing = 10
        self.axis = .vertical
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func showProgress() {
        progressView.progress = 0
        progressView.isHidden = false
    }
    func updateProgress(_ progress: Int) {
        self.isHidden = false
        progressView.setProgress(Float(progress) / 100, animated: true)
    }
}
