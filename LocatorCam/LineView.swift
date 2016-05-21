//
//  LineView.swift
//
//  You can add lines to this view, modify the line by draging its end points, and
//  remove existing lines.
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
class LineView: UIView {
    
    @IBInspectable
    private var lines: [Line] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // this is the reference for measuring, the first line added to the
    // view becomes the reference line, the length of the reference line
    // always equals to the reference object and does not change as
    // user draging and panning the line
    private var measuringReference: MeasureReference? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(frame: CGRect, reference: MeasureReference?) {
        super.init(frame: frame)
        measuringReference = reference
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            drawCircle(lines[i].startPoint, radius: lines[i].radius / 2)
            drawCircle(lines[i].endPoint, radius: lines[i].radius / 2)
            // draw distance
            if i == 0 && measuringReference != nil {
                drawText("\(String(format: "%.2f", measuringReference!.length)) \(measuringReference!.unit)", atPoint: lines[i].midPoint)
            } else if measuringReference != nil {
                drawText("\(String(format: "%.2f",lines[i].distance / lines[0].distance * CGFloat(measuringReference!.length))) \(measuringReference!.unit)", atPoint: lines[i].midPoint)
            } else {
                drawText(String(Int(lines[i].distance)), atPoint: lines[i].midPoint)
            }
        }
    }
    
    // draw circle at the line end points
    private func drawCircle(center: CGPoint, radius: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        circlePath.lineWidth = 1
        UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 0.3).set()
        circlePath.fill()
    }
    
    // draw text along the line
    private func drawText(text: String, atPoint: CGPoint) {
        
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSBackgroundColorAttributeName: UIColor(red: 0.1, green: 0.5, blue: 0.5, alpha: 0.8)
            ]
        
        let textWithAttr = NSAttributedString(string: text, attributes: textFontAttributes)
        // Creating a container for the text
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, textWithAttr.size().width, textWithAttr.size().height)

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
                    lines[i].startPoint.x = max(min(lines[i].startPoint.x + translation.x, bounds.width), 0)
                    lines[i].startPoint.y = max(min(lines[i].startPoint.y + translation.y, bounds.height), 0)
                } else if (lines[i].closeToEndPoint) {
                    lines[i].endPoint.x = max(min(lines[i].endPoint.x + translation.x, bounds.width), 0)
                    lines[i].endPoint.y = max(min(lines[i].endPoint.y + translation.y, bounds.height), 0)                }
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
    
    // remove all lines from the view
    func removeAllLines() {
        lines.removeAll()
    }
    
    // determine how many lines on the view
    func numberOfLines() -> Int {
        return lines.count
    }
    
    // set the reference object for measurement 
    func setMeasuringReference(reference: MeasureReference?) {
        measuringReference = reference
    }
}
