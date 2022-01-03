//
//  Cube.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit

class Cube: SCNNode {
    static let side: Int = 6
    var index: (Int, Int, Int)!
    
    init(index: (Int, Int, Int)) {
        self.index = index
        super.init()
        
        let box = SCNBox(width: CGFloat(Cube.side), height: CGFloat(Cube.side), length: CGFloat(Cube.side), chamferRadius: 0)
        geometry = box
        name = "cube"
        
        //physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        //physicsBody?.categoryBitMask = PhysicsCategory.emptyCube.rawValue
//        physicsBody?.collisionBitMask = PhysicsCategory.emptyCube.rawValue
       // physicsBody!.contactTestBitMask = PhysicsCategory.player.rawValue
        
        geometry?.firstMaterial?.diffuse.contents = UIColor.clear
    }
    
    func setColor(_ color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
