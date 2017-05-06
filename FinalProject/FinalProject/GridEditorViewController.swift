//
//  GridEditorViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    var name:String?
    var gridData:[[Int]]?
    var instrumentationVc = InstrumentationViewController()
    var engine:StandardEngine!
    let saveButton = UIBarButtonItem()
    
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = StandardEngine.engine
        engine.delegate = self

        gridView.theGrid = self
        gridView.size = engine.theGrid.getGridSize()
        
        loadGridData()
    }

    func loadGridData() {
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size { engine.theGrid[(i, j)] = CellState.empty }
        }
        for pos in gridData! {
            engine.theGrid[(pos[0], pos[1])] = CellState.born
        }
        self.gridView.setNeedsDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = name
        
        saveButton.title = "Save"
        saveButton.action = #selector(GridEditorViewController.saveSimulation)
        saveButton.target = self
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveSimulation() {
        if let navControl = self.navigationController {
            navControl.popViewController(animated: true)
        }
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
        
        self.gridData = []
        for i in 0..<self.gridView.size {
            for j in 0..<self.gridView.size {
                if engine.theGrid[(i, j)] == CellState.alive || engine.theGrid[(i, j)] == CellState.born {
                    self.gridData?.append([i,j])
                }
            }
        }
        InstrumentationViewController.gridState[self.name!] = self.gridData
    }
    
    func engineDidUpdate(withGrid: GridProtocol){
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (pos: Position) -> CellState {
        get { return engine.theGrid[pos] }
        set { engine.theGrid[pos] = newValue }
    }
    
    public func getGridSize() -> Int{
        return engine.theGrid.getGridSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
