//
//  PGDisplayViewController2.swift
//  ConnectSDK Example
//
//  Copyright © 2021 proglove. All rights reserved.
//

import ConnectSDK
import Foundation
import os.log
import UIKit

/// The list of all the available template IDs.
enum Template: String, CaseIterable {
    case None
    case PG1
    case PG1A
    case PG2
    case PG3
    case PG1C
    case PG2C
    case PG1E
    case PG2E
    case PG1I
    case PG2I
    case PG2A
}

/// The model containing all the data related to a template setup.
struct TemplateData {
    var numberOfFields: Int
    var isHeaderAvailable: Bool
    var isContentAvailable = true
    var isDurationTimeAvailable: Bool
}

/// The list of all the available Refresh Types.
enum RefreshTypeStrings: String, CaseIterable {
    case `default` = "Default"
    case fullRefresh = "Full refresh"
    case partialRefresh = "Partial refresh"
    
    var pgRefreshTypeModel: PGRefreshType {
        switch self {
        case .fullRefresh:
            return .fullRefresh
        case .partialRefresh:
            return .partialRefresh
        default:
            return .default
        }
    }
}

/// The list of all the available Orientations
enum OrientationStrings: String, CaseIterable {
    case none = "None"
    case north = "North"
    case east = "East"
    case south = "South"
    case west = "West"
    
    var pgOrientationModel: PGOrientation {
        switch self {
        case .east:
            return .east
        case .south:
            return .south
        case .west:
            return .west
        default:
            return .north
        }
    }
}

/// The ViewController presenting all the scanner display settings.
class PGDiplayViewController: UITableViewController {
    var centralManager: PGCentralManager?
    var cellDataCache: [IndexPath: String] = [:]
    private let log = OSLog(subsystem: OSLog.appSubsystem, category: "PGDiplayViewController")
    // Selected values
    private var selectedTemplate: Template = .None
    private var selectedRefreshType: RefreshTypeStrings = .default
    private var selectedOrientation: OrientationStrings = .none
    // Segues
    private let templatesSegue = "templatesSegue"
    private let refreshTypesSegue = "refreshTypesSegue"
    private let orientationSegue = "orientationSegue"
    // Cell identifiers
    private let durationCellIdentifier = "durationCell"
    private let entryCellIdentifier = "entryCell"
    private let cellReuseIdentifier = "standardCell"
    // Strings
    private let selectedTemplateLabelText = "Selected template"
    private let selectedRefreshTypeText = "Selected refresh type"
    private let headerLabelText = "Left Header:"
    private let rightHeaderLabelText = "Right Header:"
    private let contentLabelText = "Content:"
    private let durationLabelText = "Duration:"
    private let orientationLabelText = "Orientation:"
    // Sections
    private let orientationSection = 0
    private let templateSelectionSection = 1
    private let refreshTypeSection = 2
    // Rows
    private lazy var fieldHeaderRow: Int? = {
        let selectedTemplateData = self.templateData[self.selectedTemplate]
        return selectedTemplateData?.isHeaderAvailable == true ? 0 : nil
    }()
    private lazy var fieldHeaderRightRow: Int? = {
        let selectedTemplateData = self.templateData[self.selectedTemplate]
        return selectedTemplateData?.isHeaderAvailable == true ? 1 : 0
    }()
    private lazy var fieldContentRow: Int = {
        let selectedTemplateData = self.templateData[self.selectedTemplate]
        return selectedTemplateData?.isHeaderAvailable == true ? 2 : 0
    }()
    
    /// Detailed information regarding available templates and settings can be found at the following page:
    /// https://developers.proglove.com/insight-mobile/android/latest/ScreenTemplates.html
    private var templateData: [Template: TemplateData] = [
        .None: TemplateData(numberOfFields: 0, isHeaderAvailable: false, isContentAvailable: false, isDurationTimeAvailable: false),
        .PG1: TemplateData(numberOfFields: 1, isHeaderAvailable: true, isDurationTimeAvailable: false),
        .PG1A: TemplateData(numberOfFields: 1, isHeaderAvailable: false, isDurationTimeAvailable: false),
        .PG2: TemplateData(numberOfFields: 2, isHeaderAvailable: true, isContentAvailable: true, isDurationTimeAvailable: false),
        .PG3: TemplateData(numberOfFields: 3, isHeaderAvailable: true, isDurationTimeAvailable: false),
        .PG1C: TemplateData(numberOfFields: 1, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG2C: TemplateData(numberOfFields: 2, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG1E: TemplateData(numberOfFields: 1, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG2E: TemplateData(numberOfFields: 2, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG1I: TemplateData(numberOfFields: 1, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG2I: TemplateData(numberOfFields: 2, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true),
        .PG2A: TemplateData(numberOfFields: 2, isHeaderAvailable: false, isContentAvailable: true, isDurationTimeAvailable: true)
    ]
    
    // MARK: - Convenience methods
    
    /// Method will parse the input data and create and send SetScreen request.
    private func sendSetScreenRequest() {
        guard selectedTemplate != .None, let selectedTemplateData = templateData[selectedTemplate] else {
            return
        }
        
        let fields = templateFieldsForTemplateData(selectedTemplateData)
        let durationMs = parseDuration()
        let refreshType = selectedRefreshType.pgRefreshTypeModel
        
        // Create screen data
        let screenData = PGScreenData(templateId: selectedTemplate.rawValue, templateFields: fields, refreshType: refreshType, duration: UInt32(durationMs))
        
        // Create SetScreen command
        let command = PGCommand(screenDataRequest: screenData)
        
        // Request screen setup
        centralManager?.displayManager?.setScreen(command, completionHandler: { error in
            if let error = error {
                os_log(.error, log: self.log, "Fail to set screen: %{error}@", error.localizedDescription)
            }
        })
    }
    
    /// Method will parse the input data and create and send SetDisplayOrientation request.
    private func sendOrientationChangeRequest() {
        guard selectedOrientation != .none else {
            return
        }
        
        let orientation = PGSetDisplayOrientationRequest(orientation: selectedOrientation.pgOrientationModel)
        
        // Create set display command
        let command = PGCommand(displayOrientationRequest: orientation)
        centralManager?.displayManager?.setDisplayOrientation(command, completionHandler: { error in
            if let error = error {
                os_log(.error, log: self.log, "Fail to set screen orientation: %{error}@", error.localizedDescription)
            }
        })
    }
    
    /// Method will go through the table view and fetch the template information.
    private func templateFieldsForTemplateData(_ templateData: TemplateData) -> [PGTemplateField] {
        var fields: [PGTemplateField] = []
        for index in 0..<templateData.numberOfFields {
            // The first three sections reserved for orientation, template selection, refresh type respectively.
            let fieldSection = 3 + index
            var header = ""
            var rightHeader = ""
            var content = ""
            
            if let headerRow = fieldHeaderRow {
                let headerIndex = IndexPath(row: headerRow, section: fieldSection)
                if let headerCell = tableView.cellForRow(at: headerIndex) as? PGEntryViewCell {
                    header = headerCell.textView.text ?? ""
                } else if let cellInfo = cellDataCache[headerIndex] {
                    header = cellInfo
                }
            }
            
            if let rightHeaderRow = fieldHeaderRightRow {
                let rightHeaderIndex = IndexPath(row: rightHeaderRow, section: fieldSection)
                if let headerCell = tableView.cellForRow(at: rightHeaderIndex) as? PGEntryViewCell {
                    rightHeader = headerCell.textView.text ?? ""
                } else if let cellInfo = cellDataCache[rightHeaderIndex] {
                    rightHeader = cellInfo
                }
            }
            
            let contentIndex = IndexPath(row: fieldContentRow, section: fieldSection)
            if let contentCell = tableView.cellForRow(at: contentIndex) as? PGEntryViewCell {
                content = contentCell.textView.text ?? ""
            } else if let cellInfo = cellDataCache[contentIndex] {
                content = cellInfo
            }
            
            //Create PGTemplateField
            let templateField = PGTemplateField(
                fieldId: UInt32(index + 1),
                header: header,
                content: content,
                headerRight: rightHeader)
            fields.append(templateField)
        }
        return fields
    }
    
    /// The method will go through the table view and parse the duration.
    /// - Returns: duration
    private func parseDuration() -> Int {
        var duration = 0
        if templateData[selectedTemplate]?.isDurationTimeAvailable == true {
            let durationIndex = IndexPath(row: 1, section: refreshTypeSection)
            if let durationCell = tableView.cellForRow(at: durationIndex) as? PGDuraionViewCell {
                duration = Int(durationCell.textView.text ?? "0") ?? 0
            }
        }
        return duration
    }
    
    // MARK: - IBActions
    
    @IBAction func applyButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        // Send orientation and screen template if required.
        sendOrientationChangeRequest()
        sendSetScreenRequest()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == orientationSegue {
            if let viewController = segue.destination as? PGOrientationViewController {
                viewController.completionHandler = { selectedOrientation in
                    self.selectedOrientation = selectedOrientation
                    self.tableView.reloadData()
                }
            }
        } else if segue.identifier == templatesSegue {
            if let viewController = segue.destination as? PGTemplateViewController {
                viewController.completionHandler = { selectedTemplate in
                    self.selectedTemplate = selectedTemplate
                    self.tableView.reloadData()
                }
            }
        } else if segue.identifier == refreshTypesSegue {
            if let viewContriller = segue.destination as? PGRefreshViewController {
                viewContriller.completionHandler = { selectedRefreshOption in
                    self.selectedRefreshType = selectedRefreshOption
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Present the template selection plus orientation
        if selectedTemplate == .None {
            return 2
        }
        // Present template selection, orientation and refresh type sections plus one section for each field.
        return 3 + (templateData[selectedTemplate]?.numberOfFields ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        // Template selection, orientation and refresh type don't require section header.
        case 0, 1, 2:
            return nil
        // Template fields will have section header e.g. "Template field 1"
        default:
            return "Template field \(section - 2)"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The template selection section will have only one row.
        if section == orientationSection {
            return 1
        } else if section == templateSelectionSection {
            return 1
            
        // The refresh type selection will have only one row plus duration.
        } else if section == refreshTypeSection {
            return templateData[selectedTemplate]?.isDurationTimeAvailable ?? false ? 2 : 1
        
        // The number of rows for template field will be: 1 for content + one for header if available.
        } else {
            return templateData[selectedTemplate]?.isHeaderAvailable ?? false ? 3 : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell for orientation
        if indexPath.row == 0 && indexPath.section == orientationSection {
            let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = orientationLabelText
            cell.detailTextLabel?.text = selectedOrientation.rawValue
            return cell
            
        // Cell for template selection.
        } else if indexPath.row == 0 && indexPath.section == templateSelectionSection {
            let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = selectedTemplateLabelText
            cell.detailTextLabel?.text = selectedTemplate.rawValue
            return cell
            
        // Cell for refresh type.
        } else if indexPath.row == 0 && indexPath.section == refreshTypeSection {
            let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = selectedRefreshTypeText
            cell.detailTextLabel?.text = selectedRefreshType.rawValue
            return cell
            
        // Cell for template duration
        } else if indexPath.row == 1 && indexPath.section == 2 {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: durationCellIdentifier, for: indexPath) as? PGDuraionViewCell {
                return cell
            }
        
        // Cell for a template that has no duration enabled.
        } else if indexPath.row == 0 {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: entryCellIdentifier, for: indexPath) as? PGEntryViewCell {
                if templateData[selectedTemplate]?.isHeaderAvailable == true {
                    cell.titleLabel.text = headerLabelText
                } else {
                    cell.titleLabel.text = contentLabelText
                }
                return cell
            }
        
        // Cell for the template that has duration enabled (notifications).
        } else if indexPath.row == 1 {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: entryCellIdentifier, for: indexPath) as? PGEntryViewCell {
                if templateData[selectedTemplate]?.isHeaderAvailable == true {
                    cell.titleLabel.text = rightHeaderLabelText
                } else {
                    cell.titleLabel.text = durationLabelText
                }
                return cell
            }
        } else if indexPath.row == 2 {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: entryCellIdentifier, for: indexPath) as? PGEntryViewCell {
                if templateData[selectedTemplate]?.isHeaderAvailable == true {
                    cell.titleLabel.text = contentLabelText
                }
                return cell
            }
        }
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: entryCellIdentifier, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < 3 {
            switch (indexPath.row, indexPath.section) {
            // Orientation selection page
            case (0, 0):
                performSegue(withIdentifier: orientationSegue, sender: nil)
            // Template selection page
            case (0, 1):
                performSegue(withIdentifier: templatesSegue, sender: nil)
            // Refresh type page
            default:
                performSegue(withIdentifier: refreshTypesSegue, sender: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let entryCell = cell as? PGEntryViewCell {
            cellDataCache[indexPath] = entryCell.textView.text
        }
    }
}

// MARK: - Custom TableViewCells

class PGEntryViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
}

class PGDuraionViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextField!
}
