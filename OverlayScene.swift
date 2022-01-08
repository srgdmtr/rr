//
//  OverlayScene.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SpriteKit

protocol OverlaySceneDelegate: AnyObject {
    func didSwiped(_ direction: UISwipeGestureRecognizer.Direction)
}

class OverlayScene: SKScene {
    weak var overlaySceneDelegate: OverlaySceneDelegate?
    
//    override var isUserInteractionEnabled: Bool {
//            get { return true }
//            set { }
//        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        isUserInteractionEnabled = true
        
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        view.addGestureRecognizer(swipeGestureRecognizerLeft)
        swipeGestureRecognizerLeft.direction = .left
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        view.addGestureRecognizer(swipeGestureRecognizerRight)
        swipeGestureRecognizerRight.direction = .right
        
        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        view.addGestureRecognizer(swipeGestureRecognizerUp)
        swipeGestureRecognizerUp.direction = .up
        
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        view.addGestureRecognizer(swipeGestureRecognizerDown)
        swipeGestureRecognizerDown.direction = .down
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
                
        let location = touch.location(in: self)
        
        let touchedNodes = nodes(at: location)
        let frontTouchedNode = atPoint(location).name
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    
    @objc func respondToSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        overlaySceneDelegate?.didSwiped(recognizer.direction)
    }
}
