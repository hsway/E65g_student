//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var refreshText: UITextField!
    @IBOutlet weak var refreshSlider: UISlider!
    @IBOutlet weak var refreshToggle: UISwitch!
    @IBOutlet weak var rowsText: UITextField!
    @IBOutlet weak var colsText: UITextField!
    @IBOutlet weak var sizeStep: UIStepper!

    var engine: StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.getEngine()
        refreshSlider.value = refreshSlider.maximumValue
        refreshSlider.isEnabled = false
        refreshText.text = "\(refreshSlider.value)"
        refreshText.isEnabled = false
        refreshToggle.isOn = false
        rowsText.text = "\(engine.rows)"
        colsText.text = "\(engine.cols)"
        sizeStep.value = Double(engine.rows)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(withMessage msg:String, action: (() -> Void)? ) {
        let myalert = UIAlertController(title: "Alert!", message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            myalert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        myalert.addAction(ok)
        self.present(myalert, animated: true, completion: nil)
    }
    
    @IBAction func editRefresh(_ sender: UITextField) {
        guard let senderText = sender.text else { return }
        guard let senderDouble = Double(senderText) else {
            showAlert(withMessage: "\(senderText) is invalid.") {
                sender.text = "\(self.engine.refreshRate)"
            }
            return
        }
        if Float(senderDouble) < refreshSlider.minimumValue || Float(senderDouble) > refreshSlider.maximumValue {
            showAlert(withMessage: "\(senderDouble) is invalid.") {
                sender.text = "\(self.engine.refreshRate)"
            }
            return
        }
        refreshSlider.value = Float(senderDouble)
        engine.refreshRate = senderDouble
    }

    @IBAction func editRefreshExit(_ sender: Any) {}
    
    @IBAction func refreshSlider(_ sender: UISlider) {
        refreshText.text = "\(refreshSlider.value)"
        engine.refreshRate = Double(refreshSlider.value)
    }

    @IBAction func refreshToggleSender(_ sender: UISwitch) {
        if sender.isOn
        {
            refreshText.isEnabled = true
            refreshSlider.isEnabled = true
            engine.refreshRate = Double(refreshSlider.value)
        }
        else
        {
            refreshSlider.isEnabled = false
            refreshText.isEnabled = false
            engine.refreshRate = 0.0
        }
    }
    
    @IBAction func editRows(_ sender: UITextField) {
        guard let senderText = sender.text else { return }
        guard let senderInt = Int(senderText) else {
            showAlert(withMessage: "\(senderText) is invalid.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        if Float(senderInt) < Float(sizeStep.minimumValue) || Float(senderInt) > Float(sizeStep.maximumValue) {
            showAlert(withMessage: "\(senderInt) is invalid.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        sizeStep.value = Double(senderInt)
        fixSize(rows: senderInt, cols: senderInt)
    }
    
    @IBAction func editRowsExit(_ sender: UITextField) {}
    
    @IBAction func editCols(_ sender: UITextField) {
        guard let senderText = sender.text else { return }
        guard let senderInt = Int(senderText) else {
            showAlert(withMessage: "\(senderText) is invalid.") {
                sender.text = "\(self.engine.cols)"
            }
            return
        }
        if Float(senderInt) < Float(sizeStep.minimumValue) || Float(senderInt) > Float(sizeStep.maximumValue) {
            showAlert(withMessage: "\(senderInt) is invalid.") {
                sender.text = "\(self.engine.cols)"
            }
            return
        }
        sizeStep.value = Double(senderInt)
        fixSize(rows: senderInt, cols: senderInt)
    }
    
    @IBAction func editColsExit(_ sender: UITextField) {}
    
    @IBAction func sizeStepper(_ sender: Any) {
        let stepperInt = Int(sizeStep.value)
        fixSize(rows: stepperInt, cols: stepperInt)
    }
    
    // helper function to reset grid size
    private func fixSize(rows: Int, cols: Int) {
        if engine.rows != rows {
            engine.refreshRate = 0.0
            engine.setGridSize(rows: rows, cols: cols)
            rowsText.text = "\(rows)"
            colsText.text = "\(cols)"
        }
    }
}
