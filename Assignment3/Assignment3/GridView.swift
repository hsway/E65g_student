//
//  GridView.swift
//  Assignment3
//
//  Created by Sway,Hank on 3/25/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {

    @IBInspectable var size: Int = 20 {
        didSet {
            self.grid = Grid(self.size, self.size)
        }
    }
    
    var grid = Grid(20,20)
    
    @IBInspectable var livingColor: UIColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
    @IBInspectable var emptyColor:  UIColor = UIColor.darkGray
    @IBInspectable var bornColor:   UIColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.6)
    @IBInspectable var diedColor:   UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    @IBInspectable var gridColor:   UIColor = UIColor.black
    
    @IBInspectable var gridWidth: CGFloat = 2.0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let drawSize = CGSize(
            width: rect.size.width / CGFloat(size),
            height: rect.size.height / CGFloat(size)
        )
        let base = rect.origin
        
        // draw grid lines
        (0 ... size).forEach {
            // draw the vertical lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x + (CGFloat($0) * drawSize.width),
                    y: rect.origin.y
                ),
                end: CGPoint(
                    x: rect.origin.x + (CGFloat($0) * drawSize.width),
                    y: rect.origin.y + rect.size.height
                )
            )
            // draw the horizontal lines
            drawLine(
                start: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + (CGFloat($0) * drawSize.height)
                ),
                end: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + (CGFloat($0) * drawSize.height)
                )
            )
        }
        
        // draw circles
        (0 ..< size).forEach { i in
            (0 ..< size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * drawSize.width) + 0.5 * gridWidth,
                    y: base.y + (CGFloat(j) * drawSize.height) + 0.5 * gridWidth
                )
                
                let circleDrawSize = CGSize(
                    width: rect.size.width / CGFloat(size) - gridWidth,
                    height: rect.size.height / CGFloat(size) - gridWidth
                )
                
                let subRect = CGRect(
                    origin: origin,
                    size: circleDrawSize
                )
                
                let path = UIBezierPath(ovalIn: subRect)
                
                switch grid[(i, j)] {
                    case .alive: livingColor.setFill()
                    case .empty: emptyColor.setFill()
                    case .born:  bornColor.setFill()
                    case .died:  diedColor.setFill()
                }
                path.fill()
            }
        }
    }
    
    func drawLine(start: CGPoint, end: CGPoint) {
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
    }
    
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        lastTouchedPosition = pos
        
        let r = pos.row
        let c = pos.col
        grid[r, c] = grid[r, c].toggle(value: grid[row: r, col: c])
        
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let row = touch.location(in:self).x / (frame.size.width / CGFloat(size))
        let col = touch.location(in:self).y / (frame.size.height / CGFloat(size))
        let position = (row: Int(row), col: Int(col))
        return position
    }
    
    func next() {
        grid = grid.next()
        setNeedsDisplay()
    }
}
