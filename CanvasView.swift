//
//  CanvasView.swift
//  dr
//
//  Created by Mishunin on 26.09.2021.
//

import UIKit

protocol CanvasDelegate {
    func didEndDrawing()
}

class CanvasView: UIView {
    private var lastPoint: CGPoint = .zero
    private var drawingPath = UIBezierPath()
    private var invisibleDrawingLayer: CAShapeLayer = CAShapeLayer()
    private let mainImageView = UIImageView()
    var delegate: CanvasDelegate?  = nil
    var amplitudes: (CGPoint, CGPoint) = (.zero, .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(mainImageView)
        NSLayoutConstraint.activate([
            mainImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func OnMainViewTouchBegan(_ point: CGPoint) {
        lastPoint = point
        amplitudes.0 = point
        invisibleDrawingLayer = CAShapeLayer()
        drawingPath = UIBezierPath()
        layer.addSublayer(invisibleDrawingLayer)
    }
    
    func OnMainViewTouchMoved(_ point: CGPoint) {
        print(point)
        drawLine(from: lastPoint, to: point)
        lastPoint = point
        
        updateMaxPoints(point)
    }
    
    func OnMainViewTouchEnded(_ point: CGPoint) {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
        drawingPath.close()
        mainImageView.image = image
        
        delegate?.didEndDrawing()
    }
    
    private func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        drawingPath.move(to: fromPoint)
        drawingPath.addLine(to: toPoint)
        
        invisibleDrawingLayer.path = drawingPath.cgPath
        invisibleDrawingLayer.backgroundColor = UIColor.white.cgColor
        invisibleDrawingLayer.strokeColor = UIColor.black.cgColor
        invisibleDrawingLayer.lineWidth = 2.0
        invisibleDrawingLayer.lineCap = .round
        invisibleDrawingLayer.lineJoin = .round
    }
    
    func clear() {
        guard let sublayers = self.layer.sublayers else { return }
        for layer in sublayers {
            if let shapeLayer = layer as? CAShapeLayer, shapeLayer != self.layer {
                shapeLayer.removeFromSuperlayer()
            }
        }
    }
    
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage? {
            return UIGraphicsImageRenderer(bounds: getDrawingBoundingBox()).image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            }
        }
    
    private func updateMaxPoints(_ currentPoint: CGPoint) {
        if currentPoint.x < amplitudes.0.x {
            amplitudes.0.x = currentPoint.x
        }
        if currentPoint.y < amplitudes.0.y {
            amplitudes.0.y = currentPoint.y
        }
        if currentPoint.x > amplitudes.1.x {
            amplitudes.1.x = currentPoint.x
        }
        if currentPoint.y > amplitudes.1.y {
            amplitudes.1.y = currentPoint.y
        }
    }
    
    private func getDrawingBoundingBox() -> CGRect {
        let gap: CGFloat = 15
        let gapedRect = CGRect(x: amplitudes.0.x - gap, y: amplitudes.0.y - gap, width: amplitudes.1.x - amplitudes.0.x + 2*gap, height: amplitudes.1.y - amplitudes.0.y + 2*gap)
        
        let dimension = max(gapedRect.size.width, gapedRect.size.height)
        let xInset = (gapedRect.size.width - dimension) / 2
        let yInset = (gapedRect.size.height - dimension) / 2
        return gapedRect.insetBy(dx: xInset, dy: yInset)
    }
}

