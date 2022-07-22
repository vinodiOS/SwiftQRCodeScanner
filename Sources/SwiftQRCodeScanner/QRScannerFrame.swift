//
//  ScannerFrameView.swift
//  Pods-SwiftQRScanner_Example
//
//  Created by Vinod Jagtap on 12/22/19.
//


#if os(iOS)
import UIKit


open class QRScannerFrame: UIView {
    
    var length: CGFloat = 25.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var color: UIColor = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var radius: CGFloat = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var thickness: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        color.set()
        
        let XAdjustment = thickness / 2
        let path = UIBezierPath()
        
        // Top left
        path.move(to: CGPoint(x: XAdjustment, y: length + radius + XAdjustment))
        path.addLine(to: CGPoint(x: XAdjustment, y: radius + XAdjustment))
        path.addArc(withCenter: CGPoint(x: radius + XAdjustment, y: radius + XAdjustment), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: length + radius + XAdjustment, y: XAdjustment))
        
        // Top right
        path.move(to: CGPoint(x: frame.width - XAdjustment, y: length + radius + XAdjustment))
        path.addLine(to: CGPoint(x: frame.width - XAdjustment, y: radius + XAdjustment))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - XAdjustment, y: radius + XAdjustment), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: frame.width - length - radius - XAdjustment, y: XAdjustment))
        
        // Bottom left
        path.move(to: CGPoint(x: XAdjustment, y: frame.height - length - radius - XAdjustment))
        path.addLine(to: CGPoint(x: XAdjustment, y: frame.height - radius - XAdjustment))
        path.addArc(withCenter: CGPoint(x: radius + XAdjustment, y: frame.height - radius - XAdjustment), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: length + radius + XAdjustment, y: frame.height - XAdjustment))
        
        // Bottom right
        path.move(to: CGPoint(x: frame.width - XAdjustment, y: frame.height - length - radius - XAdjustment))
        path.addLine(to: CGPoint(x: frame.width - XAdjustment, y: frame.height - radius - XAdjustment))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - XAdjustment, y: frame.height - radius - XAdjustment), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: frame.width - length - radius - XAdjustment, y: frame.height - XAdjustment))
        
        path.lineWidth = thickness
        path.stroke()
    }
    
}

#endif
