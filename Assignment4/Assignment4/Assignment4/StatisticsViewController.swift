//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Sway,Hank on 4/10/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, GridViewDataSource {
    var engine: StandardEngine!
    var gridViewDataSource: GridViewDataSource?
    
    var alive: Int = 0
    var born: Int = 0
    var died: Int = 0
    var empty: Int = 0
    
    @IBOutlet weak var aliveLabel: UILabel!
    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var diedLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.getEngine()
        gridViewDataSource = self
        
        self.resetStats()
        self.countStats()
        self.showStats()
        
        let ncdef = NotificationCenter.default
        let nname = Notification.Name(rawValue: "EngineUpdate")
        ncdef.addObserver(
            forName: nname, object: nil,
            queue: nil) { (n) in
                self.resetStats()
                self.countStats()
                self.showStats()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get {return engine.grid[row,col]}
        set {engine.grid[row,col] = newValue}
    }
    
    private func countStats() {
        (0 ..< engine.cols).forEach { i in
            (0 ..< engine.rows).forEach { j in
                if let grid = self.gridViewDataSource {
                    switch grid[(i, j)] {
                        case .alive: alive += 1
                        case .born: born += 1
                        case .died: died += 1
                        case .empty: empty += 1
                    }
                }
            }
        }
    }
    
    private func showStats() {
        aliveLabel.text = "\(alive)"
        bornLabel.text = "\(born)"
        diedLabel.text = "\(died)"
        emptyLabel.text = "\(empty)"
    }
    
    private func resetStats() {
        alive = 0
        born = 0
        died = 0
        empty = 0
    }
}
