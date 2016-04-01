//
//  LineView1.swift
//  
//
//  Created by Yongzheng Huang on 3/31/16.
//
//

import UIKit

@IBDesignable
class LineView1: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var scale: CGFloat = 0.7 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var length: CGFloat { return max(bounds.size.width, bounds.size.height) * scale }
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var startPoint = CGPoint(x:100, y:100) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var endPoint = CGPoint(x:100, y:300) { didSet { setNeedsDisplay() } }
    var midPoint: CGPoint {
        return CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
    }
    var distance: CGFloat {
        return sqrt(pow((startPoint.x - endPoint.x), 2) + pow((startPoint.y - endPoint.y), 2))
    }
    var closeToStartPoint = false
    var closeToEndPoint = false
    var radius: CGFloat = 30
    
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
    }
    
    // draw circle at the line end points
    private func drawCircle(center: CGPoint, radius: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        circlePath.lineWidth = 1
        UIColor.darkGrayColor().set()
        circlePath.stroke()
    }
    
    // draw text along the line
    private func drawText() {
        
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
            print(initialLocation)
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
            //print(startPoint)
            //print(endPoint)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }

}
