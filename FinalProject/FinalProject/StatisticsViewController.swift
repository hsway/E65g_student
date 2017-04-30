//
//  StatisticsViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class StatisticsViewController: UIViewController, EngineDelegate {
    @IBOutlet weak var numLivingCell: UILabel!
    
    @IBOutlet weak var numBornCell: UILabel!
    
    @IBOutlet weak var numDiedCell: UILabel!
    
    @IBOutlet weak var numEmptyCell: UILabel!
    
    @IBOutlet var statisticView: UIView!
    
    
    var engine:StandardEngine!
    
    override func viewDidLoad() {
       
        // get the singleton engine from standardEngine class
        engine = StandardEngine.engine
        engine.delegate = self
        var countArray = self.engine.countCellState()
        self.numLivingCell.text = "Living:  " + countArray[0]
        self.numBornCell.text = "Born:  " + countArray[1]
        self.numDiedCell.text = "Died:  " + countArray[2]
        self.numEmptyCell.text = "Empty:  " + countArray[3]

        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                var countArray = self.engine.countCellState()
                self.numLivingCell.text = "Living:  " + countArray[0]
                self.numBornCell.text = "Born:  " + countArray[1]
                self.numDiedCell.text = "Died:  " + countArray[2]
                self.numEmptyCell.text = "Empty:  " + countArray[3]
                self.statisticView.setNeedsDisplay()
        }
        super.viewDidLoad()
    }

    // implementation of EngineDelegate protoco
    func engineDidUpdate(withGrid: GridProtocol){
        var countArray = self.engine.countCellState()
        self.numLivingCell.text = countArray[0]
        self.numBornCell.text = countArray[1]
        self.numDiedCell.text = countArray[2]
        self.numEmptyCell.text = countArray[3]
        self.statisticView.setNeedsDisplay()
    }
}
