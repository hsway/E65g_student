//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Sway,Hank on 4/10/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    @IBOutlet weak var gridView: GridView!
    
    var engine: StandardEngine!
    
    @IBAction func stepGrid(_ sender: Any) {
        if self.gridView.gridViewDataSource != nil {
            engine.grid = self.engine.step()
        }
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        let ncdef = NotificationCenter.default
        let nname = Notification.Name(rawValue: "EngineUpdate")
        let note = Notification(name: nname, object: nil, userInfo: ["engine" : self])
        ncdef.post(note)
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get {return engine.grid[row,col]}
        set {engine.grid[row,col] = newValue}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.getEngine()
        engine.delegate = self
        gridView.gridViewDataSource = self
        
        let ncdef = NotificationCenter.default
        let nname = Notification.Name(rawValue: "EngineUpdate")
        ncdef.addObserver(
            forName: nname, object: nil,
            queue: nil) {(n) in self.gridView.setNeedsDisplay()}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
