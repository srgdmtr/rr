//
//  CanvasView.swift
//  dr
//
//  Created by Mishunin on 26.09.2021.
//

import UIKit

protocol CanvasDelegate {
    func didEndDrawing()
    func didSwiped(_ dir: UISwipeGestureRecognizer.Direction)
}

class CanvasView: UIView {
    private var lastPoint: CGPoint = .zero
    private var drawingPath = UIBezierPath()
    private let invisibleDrawingLayer = CAShapeLayer()
    private let mainImageView = UIImageView()
    var delegate: CanvasDelegate?  = nil
    private var amplitudes: (CGPoint, CGPoint) = (.zero, .zero)
    private var points: [CGPoint] = []
    
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
        points.removeAll()
        lastPoint = point
        amplitudes.0 = point
        points.append(point)
        drawingPath = UIBezierPath()
        layer.addSublayer(invisibleDrawingLayer)
    }
    
    func OnMainViewTouchMoved(_ point: CGPoint) {
        points.append(point)
        drawLine(from: lastPoint, to: point)
        lastPoint = point
        
        updateMaxPoints(point)
    }
    
    func OnMainViewTouchEnded(_ point: CGPoint) {
        points.append(point)
        if let dir = swipeDirection() {
            delegate?.didSwiped(dir)
        } else {
            let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
            let image = renderer.image { rendererContext in
                self.layer.render(in: rendererContext.cgContext)
            }
            drawingPath.close()
            mainImageView.image = image
            
            delegate?.didEndDrawing()
        }
    }
    
    private func swipeDirection() -> UISwipeGestureRecognizer.Direction? {
        let samplesCount: Int = 6
        guard points.count > samplesCount else { return nil }
        let interval: (CGPoint, CGPoint) = (points.first!, points.last!)
        var samplePoints: [CGPoint] = []
        for i in 1..<samplesCount {
            let ind = i * points.count / samplesCount - 1
            guard ind < points.count - 1 else { return nil }
            samplePoints.append(points[ind])
        }
        
        let delta: CGFloat = 30 
        var dir: UISwipeGestureRecognizer.Direction? = nil
        var isLine = true
        for p in samplePoints {
            if !pointOnLine(pt1: interval.0, pt2: interval.1, pt: p) {
                isLine = false
                break
            }
        }
        
        if isLine {
            if abs(interval.0.x - interval.1.x) < delta {
                if interval.0.y < interval.1.y {
                    dir = .down
                } else {
                    dir = .up
                }
            } else if abs(interval.0.y - interval.1.y) < delta {
                if interval.0.x < interval.1.x {
                    dir = .right
                } else {
                    dir = .left
                }
            }
        }
  
        return dir
    }
    
    
    private func pointOnLine(pt1: CGPoint, pt2: CGPoint, pt: CGPoint) -> Bool {
        let d: CGFloat = 25
        
        if (pt.x - max(pt1.x, pt2.x) > d ||
                min(pt1.x, pt2.x) - pt.x > d ||
                pt.y - max(pt1.y, pt2.y) > d ||
                min(pt1.y, pt2.y) - pt.y > d) {
            return false
        }


        if abs(pt2.x - pt1.x) < d {
            let result = abs(pt1.x - pt.x) < d || abs(pt2.x - pt.x) < d
            return result
        }
        if abs(pt2.y - pt1.y) < d {
            let result = abs(pt1.y - pt.y) < d || abs(pt2.y - pt.y) < d
            return result
        }

        let x: CGFloat = pt1.x + (pt.y - pt1.y) * (pt2.x - pt1.x) / (pt2.y - pt1.y)
        let y: CGFloat = pt1.y + (pt.x - pt1.x) * (pt2.y - pt1.y) / (pt2.x - pt1.y)

        let result = abs(pt.x - x) < d || abs(pt.y - y) < d
        return result
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
        points.removeAll()
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

