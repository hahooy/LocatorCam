//
//  LineView1.swift
//  
//
//  Created by Yongzheng Huang on 3/31/16.
//
//

import UIKit

private struct Line {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var midPoint: CGPoint {
        return CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
    }
    var distance: CGFloat {
        return sqrt(pow((startPoint.x - endPoint.x), 2) + pow((startPoint.y - endPoint.y), 2))
    }
    var lineWidth: CGFloat
    var color: UIColor
    var radius: CGFloat
    var closeToStartPoint: Bool
    var closeToEndPoint: Bool
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
    var startPoint = CGPoint.zero { didSet { setNeedsDisplay() } }
    @IBInspectable
    var endPoint = CGPoint.zero { didSet { setNeedsDisplay() } }
    var midPoint: CGPoint {
        return CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
    }
    var distance: CGFloat {
        return sqrt(pow((startPoint.x - endPoint.x), 2) + pow((startPoint.y - endPoint.y), 2))
    }
    @IBInspectable
    var lineWidth: CGFloat { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor { didSet { setNeedsDisplay() } }
    var radius: CGFloat
    private var closeToStartPoint: Bool
    private var closeToEndPoint: Bool
    
    override init(frame: CGRect) {
        lineWidth = 3
        color = UIColor.blueColor()
        radius = 30
        closeToStartPoint = false
        closeToEndPoint = false
        super.init(frame: frame)
        startPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        endPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 4)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    
    override func drawRect(rect: CGRect) {
        // draw line
        let linePath = UIBezierPath()
        linePath.moveToPoint(startPoint)
        linePath.lineWidth = lineWidth
        linePath.addLineToPoint(endPoint)
        color.set()
        linePath.stroke()
        // draw circles
        drawCircle(startPoint, radius: radius)
        drawCircle(endPoint, radius: radius)
        // draw distance
        drawText(String(Int(distance)), atPoint: midPoint)
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
            // determine which point should be moved
            let initialLocation = gesture.locationInView(self)
            closeToStartPoint = closeEnough(initialLocation, pointB: startPoint, distance: radius)
            closeToEndPoint = closeEnough(initialLocation, pointB: endPoint, distance: radius)
        case .Ended: fallthrough
        case .Changed:
            // move the point if pointed by pan gesture
            let translation = gesture.translationInView(self)
            if (closeToStartPoint) {
                startPoint.x += translation.x
                startPoint.y += translation.y
            } else if (closeToEndPoint) {
                endPoint.x += translation.x
                endPoint.y += translation.y
            }
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }

}
