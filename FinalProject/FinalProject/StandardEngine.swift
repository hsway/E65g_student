//
//  StandardEngine.swift
//
//  Created by Hank Sway on 4/24/17.
//

import Foundation

// implemented by SimulationController to recieve update from this engine
protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol{
    //a var delegate of type EngineDelegate
    var delegate: EngineDelegate? {get set}
    
    //a var grid of type GridProtocol (gettable only)
    var theGrid:Grid {get}
    
    //a var refreshRate of type Double
    var timerInterval:Double{get set}
    
    //a var refreshTimer of type NSTimer
    var timer: Timer? {get set}
    
    //an initializer taking
    init(size: Int)
    
    //a func step() which takes no arguments and return an object of type GridProtocol
    func step()
    
}

class StandardEngine: EngineProtocol {
    
    //Create a singleton of StandardEngine in a lazy manner
    //It creates a grid of size 10x10 by default
    static var engine: StandardEngine = StandardEngine(size: 60)
    
    var theGrid: Grid
    var delegate: EngineDelegate?
    
    var updateClosure: ((Grid) -> Void)?
    var timer: Timer?
    var timerInterval: TimeInterval = 0.0 {
        didSet {
            if timerInterval > 0.0 {
                timer = Timer.scheduledTimer(
                    withTimeInterval: timerInterval,
                    repeats: true
                ) { (t: Timer) in
                    self.step()
                }
            }
            else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    required init(size: Int) {
        self.theGrid = Grid(size, size, cellInitializer: allEmptyInitializer )
    }
    
    func step() {
        // set the next grid to be the singleton of the engine
        StandardEngine.engine.theGrid = self.theGrid.next()
        
        // notify the delegate with the delegate method
        delegate?.engineDidUpdate(withGrid: self.theGrid)
        
        // Whenever the grid is created or changed publish the grid object using an NSNotification.
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                           object: nil,
                           userInfo: ["engine" : self])
                           nc.post(n)
    }
    
    // return an array has the string value of the count of alive, born, died and empty cells
    func countCellState() -> [String] {
        var aliveCount = 0
        var bornCount = 0
        var diedCount = 0
        var emptyCount = 0

        let cells = theGrid.getCells()
        for i in cells{
            for j in i{
                if j.state == CellState.alive{
                    aliveCount += 1
                }else if j.state == CellState.born{
                    bornCount += 1
                }else if j.state == CellState.died{
                    diedCount += 1
                }else if j.state == CellState.empty{
                   emptyCount += 1
                }
            }
        }
        let res = [String(aliveCount), String(bornCount), String(diedCount), String(emptyCount)]
        return res
    }
    
}
