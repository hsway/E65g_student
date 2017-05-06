//
//  StandardEngine.swift
//
//  Created by Hank Sway on 4/24/17.
//

import Foundation

protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var theGrid: Grid { get }
    var timerInterval: Double { get set }
    var timer: Timer? { get set }
    init(size: Int)
    func step()
}

class StandardEngine: EngineProtocol {
    
    // setting higher to account for patterns defined in JSON file
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
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    required init(size: Int) {
        self.theGrid = Grid(
            size,
            size,
            cellInitializer: allEmptyInitializer
        )
    }
    
    func countCellState() -> [String] {
        var aliveCount = 0
        var bornCount = 0
        var diedCount = 0
        var emptyCount = 0
        
        let cells = theGrid.getCells()
        for i in cells {
            for j in i {
                if j.state == CellState.alive { aliveCount += 1 }
                else if j.state == CellState.born { bornCount += 1 }
                else if j.state == CellState.died { diedCount += 1 }
                else if j.state == CellState.empty { emptyCount += 1 }
            }
        }
        
        let res = [
            String(aliveCount),
            String(bornCount),
            String(diedCount),
            String(emptyCount)
        ]
        return res
    }
    
    func step() {
        StandardEngine.engine.theGrid = self.theGrid.next()
        delegate?.engineDidUpdate(withGrid: self.theGrid)
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(
            name: name,
            object: nil,
            userInfo: ["engine" : self]
        )
        nc.post(n)
    }
}
