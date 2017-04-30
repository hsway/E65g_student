//
//  GridEditorViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    var titleName:String?
    var gridStateData:[[Int]]?
    let saveButton = UIBarButtonItem()
    
    var instrumentationVc = InstrumentationViewController()
    @IBOutlet weak var gridView: GridView!
    var engine:StandardEngine!
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the singleton engine from standardEngine class
        engine = StandardEngine.engine
        
        // set the griddatasource of the gridview to be this griddatasource
        gridView.theGrid = self
        
        // set delegate to recieve notification from standard engine
        engine.delegate = self
        
        gridView.size = engine.theGrid.getGridSize()
        
        loadGridStateData()
    }

    func loadGridStateData() {
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = titleName
        
        saveButton.title = "Save"
        saveButton.action = #selector(GridEditorViewController.saveToSimulationController)
        saveButton.target = self
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // function triggered by save button
    func saveToSimulationController(){
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        // notify engine change
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
        self.gridStateData = []
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                if engine.theGrid[(i, j)] == CellState.alive || engine.theGrid[(i, j)] ==  CellState.born  {
                    self.gridStateData?.append([i,j])
                }
            }
        }
        InstrumentationViewController.gridStateDataDict[self.titleName!] = self.gridStateData
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
