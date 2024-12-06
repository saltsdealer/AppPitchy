//
//  GraphView.swift
//  pitchy
//
//  Created by firesalts on 7/27/24.
//

import UIKit

class SpectrumViewDrawer: UIView {
    
    var lineWidth: CGFloat = 2.0
    
    private let bottomSpace: CGFloat = 20.0
    private let topSpace: CGFloat = 20.0
    private let leftSpace: CGFloat = 40.0
    private let rightSpace: CGFloat = 20.0
    
    private var xAxisLabel: String? = nil
    private var yAxisLabel: String? = nil
    
    var gradientLayer = CAGradientLayer()
    
    var frequencies: [Float] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "GraphBackground")
        gradientLayer.colors = [UIColor(named: "GraphLine")?.cgColor,
                                UIColor(red: 15/255, green: 52/255, blue: 67/255, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.6, 1.0]
        self.layer.addSublayer(gradientLayer)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard frequencies.count > 1 else { return }
        
        drawAxes(in: rect)
        
        let path = UIBezierPath()
        
        for (i, frequency) in frequencies.enumerated() {
            let x = leftSpace + CGFloat(i) * (bounds.width - leftSpace - rightSpace) / CGFloat(frequencies.count - 1)
            let y = translateFrequencyToYPosition(frequency: frequency)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        gradientLayer.frame = CGRect(x: leftSpace, y: topSpace, width: bounds.width - leftSpace - rightSpace, height: bounds.height - topSpace - bottomSpace)
        gradientLayer.mask = shapeLayer
    }
    
    private func drawAxes(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // Draw x-axis
        context?.move(to: CGPoint(x: leftSpace, y: bounds.height - bottomSpace))
        context?.addLine(to: CGPoint(x: bounds.width - rightSpace, y: bounds.height - bottomSpace))
        
        // Draw y-axis
        context?.move(to: CGPoint(x: leftSpace, y: bounds.height - bottomSpace))
        context?.addLine(to: CGPoint(x: leftSpace, y: topSpace))
        
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(1.0)
        context?.strokePath()
        
        
          // Add labels if they are set
          let paragraphStyle = NSMutableParagraphStyle()
          paragraphStyle.alignment = .center
          
          let attributes = [
              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
              NSAttributedString.Key.foregroundColor: UIColor.white,
              NSAttributedString.Key.paragraphStyle: paragraphStyle
          ]
          
        // Draw X-axis label
        if let xLabel = xAxisLabel {
            let label = NSString(string: xLabel)
            // Place label at the bottom center of the X-axis
            label.draw(at: CGPoint(x: bounds.width / 2 - 30, y: bounds.height - 15), withAttributes: attributes)
        }
        
        // Draw Y-axis label
        if let yLabel = yAxisLabel {
            let label = NSString(string: yLabel)
            let labelSize = label.size(withAttributes: attributes)
            
            // Rotate and draw Y-axis label vertically beside the Y-axis
            context?.saveGState()
            context?.translateBy(x: leftSpace - 30, y: bounds.height / 2 + labelSize.width / 2)
            context?.rotate(by: -CGFloat.pi / 2) // Rotate 90 degrees counterclockwise
            label.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
            context?.restoreGState()
        }
    }
    
    
    func setAxisLabels(xLabel: String?, yLabel: String?) {
        self.xAxisLabel = xLabel
        self.yAxisLabel = yLabel
        setNeedsDisplay() // Trigger a redraw to show the updated labels
    }

    
    private func translateFrequencyToYPosition(frequency: Float) -> CGFloat {
        let maxFrequency = frequencies.max() ?? 1
        let barHeight: CGFloat = CGFloat(frequency / maxFrequency) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
}
