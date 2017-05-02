//
//  GridView.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

public protocol GridViewDataSource {
    subscript (pos: Position) -> CellState { get set }
    func getGridSize() -> Int
}

@IBDesignable class GridView: UIView {
    
    // setting higher to account for patterns defined in JSON file
    @IBInspectable var size: Int = 60
    
    @IBInspectable var livingColor: UIColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
    @IBInspectable var emptyColor:  UIColor = UIColor.darkGray
    @IBInspectable var bornColor:   UIColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.6)
    @IBInspectable var diedColor:   UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    @IBInspectable var gridColor:   UIColor = UIColor.black
    
    @IBInspectable var gridWidth: CGFloat = 0.0
    
    var theGrid: GridViewDataSource?

    override func draw(_ rect: CGRect) {
        let size = CGSize(
            width: rect.size.width / CGFloat((self.size)),
            height: rect.size.height / CGFloat((self.size))
        )
       
        let base = rect.origin
        (0 ... self.size).forEach { i in
            (0 ..< self.size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y + (CGFloat(j) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                let p = Position(i,j)
             
                if let theGrid = theGrid {
                    switch theGrid[p].description() {
                        
                    case "born" :
                        let path = UIBezierPath(ovalIn: subRect)
                        bornColor.setFill()
                        path.fill()
                        
                    case "empty" :
                        let path = UIBezierPath(ovalIn: subRect)
                        emptyColor.setFill()
                        path.fill()
                       
                    case "alive" :
                        let path = UIBezierPath(ovalIn: subRect)
                        livingColor.setFill()
                        path.fill()
                       
                    case "died" :
                        let path = UIBezierPath(ovalIn: subRect)
                        diedColor.setFill()
                        path.fill()
                    default: break
                    }
                }
            }
        }
        
        (0 ... self.size).forEach {
            drawLine(
                start: CGPoint(x: CGFloat($0)/CGFloat(self.size) * rect.size.width, y: 0.0),
                end:   CGPoint(x: CGFloat($0)/CGFloat(self.size) * rect.size.width, y: rect.size.height)
            )
            
            drawLine(
                start: CGPoint(x: 0.0, y: CGFloat($0)/CGFloat(self.size) * rect.size.height ),
                end: CGPoint(x: rect.size.width, y: CGFloat($0)/CGFloat(self.size) * rect.size.height)
            )
        }
    }
    
    func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        path.lineWidth = gridWidth
        path.move(to: start)
        path.addLine(to: end)
        gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        if theGrid != nil {
            theGrid![(Int(pos.row),Int(pos.col))] = theGrid![(Int(pos.row),Int(pos.col))].isAlive ? .empty : .alive
            setNeedsDisplay()
        }
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let col = touchY / gridHeight * CGFloat(size)
        
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let row = touchX / gridWidth * CGFloat(size)
        
        return GridPosition(row: Int(row), col: Int(col))
    }
}
