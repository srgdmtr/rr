//
//  WorldUpdtaeTriggerNode.swift
//  gggggg
//
//  Created by Mishunin on 03.01.2022.
//

import SceneKit

class WorldUpdtaeTriggerNode: SCNNode {
    
    override init() {
        super.init()
        
        let backBox = SCNBox(width: CGFloat(Cube.side), height: CGFloat(Cube.side), length: 0.1, chamferRadius: 0)
        let backNode = SCNNode(geometry: backBox)
        backNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: backBox, options: nil))
        backNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        backNode.physicsBody?.categoryBitMask = PhysicsCategory.worldUpdtaeTriggerNode.rawValue
        backNode.physicsBody?.contactTestBitMask = PhysicsCategory.worldPieceFrontEdge.rawValue
        backNode.name = "worldUpdtaeTriggerNode"
        //backNode.isHidden = true
        self.addChildNode(backNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
