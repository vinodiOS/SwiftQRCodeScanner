//
//  SquareView.swift
//  Pods-SwiftQRScanner_Example
//
//  Created by Vinod Jagtap on 12/22/19.
//

import UIKit

open class SquareView: UIView {
    
    var sizeMultiplier : CGFloat = 0.1 {
        didSet { self.draw(self.bounds) }
    }
    
    var lineWidth : CGFloat = 2 {
        didSet { self.draw(self.bounds) }
    }
    
    var lineColor : UIColor = UIColor.green {
        didSet { self.draw(self.bounds) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    func drawCorners() {
        let rectCornerContext = UIGraphicsGetCurrentContext()
        
        rectCornerContext?.setLineWidth(lineWidth)
        rectCornerContext?.setStrokeColor(lineColor.cgColor)
        
        //top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.strokePath()
        
        //top rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //bottom rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        rectCornerContext?.strokePath()
        
        //bottom left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //second part of top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.strokePath()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawCorners()
    }
    
}
