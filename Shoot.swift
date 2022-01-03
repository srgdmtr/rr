//
//  Shoot.swift
//  gggggg
//
//  Created by Mishunin on 03.01.2022.
//

import SceneKit

class Shoot: SCNNode {
   
    
    override init() {
        super.init()
        
        let box = SCNBox(width: CGFloat(1), height: CGFloat(1), length: CGFloat(1), chamferRadius: 0)
        geometry = box
        name = "shoot"
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.categoryBitMask = PhysicsCategory.shoot.rawValue
        //physicsBody?.collisionBitMask = PhysicsCategory.emptyCube.rawValue
        physicsBody!.contactTestBitMask = PhysicsCategory.enemy.rawValue
        
        geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
    
    func setColor(_ color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
