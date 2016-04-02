//
//  LineView1.swift
//  
//
//  Created by Yongzheng Huang on 3/31/16.
//
//

import UIKit

private struct Line {
    var startPoint = CGPoint.zero
    var endPoint = CGPoint.zero
    var midPoint: CGPoint {
        return CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
    }
    var distance: CGFloat {
        return sqrt(pow((startPoint.x - endPoint.x), 2) + pow((startPoint.y - endPoint.y), 2))
    }
    var lineWidth: CGFloat = 3
    var color: UIColor = UIColor.blueColor()
    var radius: CGFloat = 30
    var closeToStartPoint = false
    var closeToEndPoint = false
}

@IBDesignable
class LineView1: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable
    private var lines: [Line] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    
    override func drawRect(rect: CGRect) {
        // draw all lines
        for i in 0..<lines.count {
            // draw line
            let linePath = UIBezierPath()
            linePath.moveToPoint(lines[i].startPoint)
            linePath.lineWidth = lines[i].lineWidth
            linePath.addLineToPoint(lines[i].endPoint)
            lines[i].color.set()
            linePath.stroke()
            // draw circles
            drawCircle(lines[i].startPoint, radius: lines[i].radius)
            drawCircle(lines[i].endPoint, radius: lines[i].radius)
            // draw distance
            drawText(String(Int(lines[i].distance)), atPoint: lines[i].midPoint)
        }
    }
    
    // draw circle at the line end points
    private func drawCircle(center: CGPoint, radius: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        circlePath.lineWidth = 1
        UIColor.darkGrayColor().set()
        circlePath.stroke()
    }
    
    // draw text along the line
    private func drawText(text: String, atPoint: CGPoint) {
        
        let textColor: UIColor = UIColor.blackColor()
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, self.bounds.width - atPoint.x, self.bounds.height - atPoint.y)
        //Now Draw the text into an image.
        text.drawInRect(rect, withAttributes: textFontAttributes)
    }
    
    // determine if two points are closer than the specified distance
    private func closeEnough(pointA: CGPoint, pointB: CGPoint, distance: CGFloat) -> Bool {
        return sqrt(pow((pointA.x - pointB.x), 2) + pow((pointA.y - pointB.y), 2)) < distance
    }
    
    // move the line end point pointed by pan gesture
    func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            for i in 0..<lines.count {
                // determine which point should be moved
                let initialLocation = gesture.locationInView(self)
                lines[i].closeToStartPoint = closeEnough(initialLocation, pointB: lines[i].startPoint, distance: lines[i].radius)
                lines[i].closeToEndPoint = closeEnough(initialLocation, pointB: lines[i].endPoint, distance: lines[i].radius)
            }
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            for i in 0..<lines.count {
                // move the point if pointed by pan gesture
                if (lines[i].closeToStartPoint) {
                    lines[i].startPoint.x += translation.x
                    lines[i].startPoint.y += translation.y
                } else if (lines[i].closeToEndPoint) {
                    lines[i].endPoint.x += translation.x
                    lines[i].endPoint.y += translation.y
                }
                gesture.setTranslation(CGPointZero, inView: self)
            }
        default: break
        }
    }
    
    // add a line to view
    func addLine() {
        var line = Line()
        line.startPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        line.endPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 4)
        lines.append(line)
    }
    
    // remove a line from the view
    func removeLine() {
        lines.popLast()
    }
}
