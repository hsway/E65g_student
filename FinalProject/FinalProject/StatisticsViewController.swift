//
//  StatisticsViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class StatisticsViewController: UIViewController, EngineDelegate {
    @IBOutlet weak var alive: UILabel!
    @IBOutlet weak var born: UILabel!
    @IBOutlet weak var died: UILabel!
    @IBOutlet weak var empty: UILabel!
    @IBOutlet var statsView: UIView!
    
    var engine:StandardEngine!
    
    override func viewDidLoad() {
        engine = StandardEngine.engine
        engine.delegate = self
        var countArray = self.engine.countCellState()
        self.alive.text = "Alive:  " + countArray[0]
        self.born.text = "Born:  " + countArray[1]
        self.died.text = "Died:  " + countArray[2]
        self.empty.text = "Empty:  " + countArray[3]

        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil
        ) { (n) in
            var countArray = self.engine.countCellState()
            self.alive.text = "Alive:  " + countArray[0]
            self.born.text = "Born:  " + countArray[1]
            self.died.text = "Died:  " + countArray[2]
            self.empty.text = "Empty:  " + countArray[3]
            self.statsView.setNeedsDisplay()
        }
        super.viewDidLoad()
    }

    // EngineDelegate protocol
    func engineDidUpdate(withGrid: GridProtocol) {
        var countArray = self.engine.countCellState()
        self.alive.text = countArray[0]
        self.born.text = countArray[1]
        self.died.text = countArray[2]
        self.empty.text = countArray[3]
        self.statsView.setNeedsDisplay()
    }
}
