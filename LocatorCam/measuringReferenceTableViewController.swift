//
//  measuringReferenceTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/16/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class measuringReferenceTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Properties
    
    @IBOutlet weak var unitPicker: UIPickerView!
    
    // units
    enum Unit: String {
        case Inch = "inch"
        case Foot = "foot"
        case Milimeter = "mm"
        case Centimeter = "cm"
        case Meter = "m"
    }
    
    let units = [Unit.Inch, Unit.Foot, Unit.Milimeter, Unit.Centimeter, Unit.Meter]
    let scales = [1, Constant.inchToFoot, Constant.inchToMm, Constant.inchToCm, Constant.inchToM]
    var baseMeasuringReferences = [MeasureReference]() {
        didSet {
            saveReferences()
            let selectedUnit = unitPicker.selectedRow(inComponent: 0)
            convertToUnit(units[selectedUnit], scale: scales[selectedUnit])
        }
    }
    var measuringReferences = [MeasureReference]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    struct Constant {
        static let predefinedLengthCell = "predefined length"
        static let customLengthCell = "custom length"
        static let unwindFromPredefinedReference = "unwind from predefined reference to edit board"
        static let unwindFromCustomReference = "unwind from custom reference to edit board"
        static let unwindFromNewReference = "unwindFromNewReferenceToReferenceTable"
        static let unwindFromScanner = "unwindFromScannerToReferenceTable"
        static let inchToFoot = 0.08333
        static let inchToMm = 25.4
        static let inchToCm = 2.54
        static let inchToM = 0.0254
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        if let refs = loadReferences() {
            print("load references")
            baseMeasuringReferences = refs
        } else {
            // if there is no references store in the documents,
            // load sample references and save them in the documents.
            loadSampleReferences()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return measuringReferences.count
        case 1:
            return 1
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Predefined"
        } else if section == 1 {
            return "Custom"
        } else if section == 2{
            return "QRCode"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.predefinedLengthCell, for: indexPath)
            let reference = measuringReferences[indexPath.row]
            cell.textLabel?.text = reference.name
            cell.detailTextLabel?.text = "\(String(format: "%.2f", reference.length)) \(reference.unit)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.customLengthCell, for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.unwindFromPredefinedReference, sender: tableView.cellForRow(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            baseMeasuringReferences.remove(at: indexPath.row)
        } else {
            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }
    
    // MARK: - picker view data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch units[row] {
        case .Centimeter:
            convertToUnit(.Centimeter, scale: Constant.inchToCm)
        case .Foot:
            convertToUnit(.Foot, scale: Constant.inchToFoot)
        case .Milimeter:
            convertToUnit(.Milimeter, scale: Constant.inchToMm)
        case .Meter:
            convertToUnit(.Meter, scale: Constant.inchToM)
        case .Inch:
            convertToUnit(.Inch, scale: 1)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editPhotoViewController = segue.destination as? EditPhotoVC {
            if segue.identifier == Constant.unwindFromPredefinedReference {
                if let selectedRow = tableView.indexPathForSelectedRow?.row {
                    editPhotoViewController.measuringReference = measuringReferences[selectedRow]
                }
            } else if segue.identifier == Constant.unwindFromCustomReference {
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? CustomLengthTableViewCell {
                    if cell.customLengthInput.text != nil && cell.customUnitInput.text != nil {
                        let customLength = Double(cell.customLengthInput.text!) ?? 0
                        editPhotoViewController.measuringReference = MeasureReference(name: "Custom", length: customLength, unit: cell.customUnitInput.text!)
                    } else {
                        editPhotoViewController.measuringReference = nil
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToReferenceTable(_ segue: UIStoryboardSegue) {
        if segue.identifier == Constant.unwindFromNewReference {
            if let sourceViewController = segue.source as? NewReferenceViewController {
                baseMeasuringReferences.append(sourceViewController.measuringReference!)
            }
        }
        if segue.identifier == Constant.unwindFromScanner {
            if let sourceViewController = segue.source as? QRScannerViewController {
                print("unwinded to reference table")
                baseMeasuringReferences.append(sourceViewController.measuringReference!)
            }
        }
    }
    
    // MARK: - NSCoding
    
    
    func saveReferences() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(baseMeasuringReferences, toFile: MeasureReference.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save references...")
        } else {
            print("Saved references...")
        }
    }
    
    func loadReferences() -> [MeasureReference]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: MeasureReference.ArchiveURL.path) as? [MeasureReference]
    }
    
    // MARK: - helper function
    
    // populate the measuring references with sample references
    fileprivate func loadSampleReferences() {
        // predefined measuring references
        let sampleMeasuringReferences: [(String, Double, String)] = [("Drivers License (width)", 3.375, "inches"), ("Drivers License (length)", 3.622, "inches"), ("iPhone 5 (height)", 4.87, "inches"), ("iPhone 5 (width)", 2.31, "inches"), ("iPhone 6 (height)", 5.44, "inches"), ("iPhone 6 plus (height)", 6.22, "inches")]
        
        for reference in sampleMeasuringReferences {
            baseMeasuringReferences.append(MeasureReference(name: reference.0, length: reference.1, unit: reference.2))
        }
    }
    
    fileprivate func convertToUnit(_ newUnit: Unit, scale: Double) {
        measuringReferences = [MeasureReference]()
        for reference in baseMeasuringReferences {
            measuringReferences.append(MeasureReference(name: reference.name, length: reference.length * scale, unit: newUnit.rawValue))
        }
    }
}
