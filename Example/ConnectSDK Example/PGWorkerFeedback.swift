//
//  PGWorkerFeedback.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import ConnectSDK
import UIKit

class PGWorkerFeedbackViewController: UITableViewController {
    var centralManager: PGCentralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            triggerFeedback(.success)
        case 1:
            triggerFeedback(.error)
        case 2:
            triggerFeedback(.special1)
        case 3:
            triggerFeedback(.special2)
        case 4:
            triggerFeedback(.special3)
        default:
            return
        }
    }
    
    func triggerFeedback(_ feedback: PGPredefinedFeedback) {
        let feedbackRequest = PGFeedbackRequest(feedback: feedback)
        let command = PGCommand(feedbackRequest)
        centralManager?.feedbackManager?.playFeedbackSequence(withFeedbackCommand: command, completionHandler: { error in
            if let error = error {
                print(error)
            }
        })
    }
}
