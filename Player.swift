//
//  Player.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit

enum MoveDirection {
    case left, right
}


class Player: SCNNode {
    
    override init() {
        super.init()
        
        let box = SCNBox(width: CGFloat(Cube.side), height: CGFloat(Cube.side), length: CGFloat(Cube.side), chamferRadius: 0)
        self.geometry = box
        self.name = "player"
        self.geometry?.firstMaterial?.shininess = 1.0
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: box, options: nil))
        self.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.staticCube.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.staticCube.rawValue
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        self.physicsBody?.velocityFactor = SCNVector3(0, 1, 0)
        self.physicsBody?.angularVelocityFactor = SCNVector3(0, 0, 0)
        //self.physicsBody?.damping = 0
        //physicsBody?.velocity = SCNVector3(0, 0, 0)
        self.physicsBody?.mass = 60
        
    
    }
    
    func update() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveTo(_ dir: MoveDirection) {
        if dir == .left {
            runAction(SCNAction.move(by: SCNVector3(-Cube.side, 0, 0), duration: 0.1))
        } else if dir == .right {
            runAction(SCNAction.move(by: SCNVector3(Cube.side, 0, 0), duration: 0.1))
        }
    }
    
    func jump() {
//        let a = SCNAction.run { i in
//            i.physicsBody?.type = .kinematic
//        }
//        let b = SCNAction.run { i in
//            i.physicsBody?.type = .dynamic
//        }
//        let bounceUpAction = SCNAction.moveBy(x: 0, y: CGFloat(Cube.side), z: 0, duration: 1)
//        let bounceDownAction = SCNAction.moveBy(x: 0, y: -CGFloat(Cube.side), z: 0, duration: 0.5)
//        let bounceAction = SCNAction.sequence([a, bounceUpAction, bounceDownAction, b])
//        runAction(bounceAction)
        physicsBody?.applyForce(SCNVector3Make(0, 3000, 0), asImpulse: true) 
        
    }
   
    
}
