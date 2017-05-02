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
    // array representation of the grid state
    var gridStateData:[[Int]]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the singleton engine from standardEngine class
        engine = StandardEngine.engine
        
        // set the griddatasource of the gridview to be this griddatasource
        gridView.theGrid = self
        
        // set delegate to recieve notification from standard engine
        engine.delegate = self
        
        gridView.size = engine.theGrid.getGridSize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userDefaults = appDelegate.userDefaults
        if userDefaults?.value(forKey: "pattern") != nil {
            // do something here when a pattern exists
            loadGridStateData(gridStateData:userDefaults?.value(forKey: "pattern") as? [[Int]])
        }
        
        // add observer to get notification from standard engine
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
    
    func loadGridStateData(gridStateData:[[Int]]?) {
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                engine.theGrid[(i, j)] = CellState.empty
            }
        }
        for pos in gridStateData! {
            engine.theGrid[(pos[0], pos[1])] = CellState.born
        }
        
        self.gridView.setNeedsDisplay()
    }
    
    @IBAction func SaveToTableView(_ sender: Any) {
        
        gridStateData = []
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                if engine.theGrid[(i, j)] == CellState.alive || engine.theGrid[(i, j)] ==  CellState.born  {
                    gridStateData?.append([i,j])
                }
            }
        }
        
        let alertController = UIAlertController(title: "Pattern Name?", message: "Please input your pattern name:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                if let text = field.text {
                    if !InstrumentationViewController.tableStrings.contains(text){
                        InstrumentationViewController.tableStrings.append(text)
                        InstrumentationViewController.gridState[text] = self.gridStateData
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                        
                    }else{
                        let nameTakenAlert = UIAlertController(title: "Error", message:
                            "\"\(text)\" already exsits", preferredStyle: UIAlertControllerStyle.alert)
                        nameTakenAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(nameTakenAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = ""
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pattern = self.gridStateData!
        
        
        let file = "data"
        let text = "[{ \"saved\" : \(gridStateData!.description)}]"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(file)
            do {
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                engine.theGrid[(i, j)] = CellState.empty
            }
        }
        self.gridView.setNeedsDisplay()
        // Whenever the grid is created or changed publish the grid object using an NSNotification.
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func sizeStepper(_ sender: UIStepper) {
        engine.theGrid = Grid(Int(sender.value), Int(sender.value))
        gridView.size = engine.theGrid.getGridSize()
    }
    
    
    // push step button to make the grid to change at 1second per state
    @IBAction func nextGrid(_ sender: Any) {
        engine.step()
        gridView.setNeedsDisplay()
    }
    
    
    // implementation of EngineDelegate protocol
    func engineDidUpdate(withGrid: GridProtocol){
        self.gridView.setNeedsDisplay()
    }
    
    // implementation of GridViewDataSource protocol
    public subscript (pos: Position) -> CellState {
        get {  return engine.theGrid[pos] }
        set {  engine.theGrid[pos] = newValue }
    }
    public func getGridSize() -> Int{
        return engine.theGrid.getGridSize()
    }
}
