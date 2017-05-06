//
//  SimulationViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    @IBOutlet weak var gridView: GridView!
    
    var engine:StandardEngine!
    var timer: Timer?
    var gridArray: [[Int]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = StandardEngine.engine
        engine.delegate = self
        gridView.theGrid = self
        gridView.size = engine.theGrid.getGridSize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userDefaults = appDelegate.userDefaults
        if userDefaults?.value(forKey: "pattern") != nil {
            loadGridData(gridArray:userDefaults?.value(forKey: "pattern") as? [[Int]])
        }
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.size = self.engine.theGrid.getGridSize()
                self.gridView.setNeedsDisplay()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func loadGridData(gridArray:[[Int]]?) {
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                engine.theGrid[(i, j)] = CellState.empty
            }
        }
        for pos in gridArray! {
            engine.theGrid[(pos[0], pos[1])] = CellState.born
        }
        self.gridView.setNeedsDisplay()
    }
    
    @IBAction func reset(_ sender: Any) {
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                engine.theGrid[(i, j)] = CellState.empty
            }
        }
        self.gridView.setNeedsDisplay()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    @IBAction func next(_ sender: Any) {
        engine.step()
        gridView.setNeedsDisplay()
    }
    
    @IBAction func saveGrid(_ sender: Any) {
        gridArray = []
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                if engine.theGrid[(i, j)] == CellState.alive || engine.theGrid[(i, j)] == CellState.born {
                    gridArray?.append([i,j])
                }
            }
        }
        
        let ac = UIAlertController(
            title: "New Pattern",
            message: "Please input your pattern name:",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = ac.textFields?[0] {
                if let text = field.text {
                    if !InstrumentationViewController.tableStrings.contains(text){
                        InstrumentationViewController.tableStrings.append(text)
                        InstrumentationViewController.gridState[text] = self.gridArray
                        NotificationCenter.default.post(
                            name: NSNotification.Name(rawValue: "load"),
                            object: nil
                        )
                    } else {
                        let nameTakenAlert = UIAlertController(
                            title: "Error",
                            message: "\"\(text)\" already exists",
                            preferredStyle: UIAlertControllerStyle.alert
                        )
                        nameTakenAlert.addAction(UIAlertAction(
                            title: "Dismiss",
                            style: UIAlertActionStyle.default,
                            handler: nil
                        ))
                        self.present(nameTakenAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        ac.addTextField { (textField) in textField.placeholder = "" }
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
        self.present(ac, animated: true, completion: nil)
        
        let ad = UIApplication.shared.delegate as! AppDelegate
        ad.pattern = self.gridArray!
        
        let file = "data"
        let text = "[{ \"saved\" : \(gridArray!.description)}]"
        if let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first {
            let path = dir.appendingPathComponent(file)
            do { try text.write(to: path, atomically: false, encoding: String.Encoding.utf8) }
            catch {}
        }
    }
    
    // EngineDelegate protocol
    func engineDidUpdate(withGrid: GridProtocol){
        self.gridView.setNeedsDisplay()
    }
    
    // GridViewDataSource protocol
    public subscript (pos: Position) -> CellState {
        get {  return engine.theGrid[pos] }
        set {  engine.theGrid[pos] = newValue }
    }
    
    public func getGridSize() -> Int{
        return engine.theGrid.getGridSize()
    }
}
