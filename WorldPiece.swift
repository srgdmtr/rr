//
//  WorldPiece.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit

protocol WorldPieceDelegate: AnyObject {
    func playerDidEnterPiece(with index: Int)
}

class WorldPiece: SCNNode {
    enum SliceAxis {
        case horizontal, vertical
    }
    static let cubesInRow: Int = 5
    weak var delegate: WorldPieceDelegate? = nil
    var index: Int = 0
    var cubes: [[[Cube]]] = []
    let moveForwardAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3(0, 0, 10), duration: 1))
    var frontCollisionPlaneNode = SCNNode()
    
    
    override init() {
        super.init()
        
        let pieceSide = CGFloat(Cube.side * WorldPiece.cubesInRow)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceSide, chamferRadius: 0)
        geometry = box
        geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        name = "worldPiece"
        
        initCubes()
        
        let collisionEdge = SCNBox(width: pieceSide, height: pieceSide, length: 0, chamferRadius: 0)
        frontCollisionPlaneNode = SCNNode(geometry: collisionEdge)
        frontCollisionPlaneNode.position = SCNVector3Make(0, 0.1, Float(pieceSide / 2))

        frontCollisionPlaneNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: collisionEdge, options: nil))
        frontCollisionPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        //frontCollisionPlaneNode.opacity = 0.5
        frontCollisionPlaneNode.physicsBody?.categoryBitMask = PhysicsCategory.worldPieceFrontEdge.rawValue
        frontCollisionPlaneNode.physicsBody?.contactTestBitMask = PhysicsCategory.backPlayerNode.rawValue
        //frontCollisionPlaneNode.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        frontCollisionPlaneNode.name = "worldPieceFrontEdge"
        frontCollisionPlaneNode.physicsBody!.mass = 0
        addChildNode(frontCollisionPlaneNode)
    }
    
    private func initCubes() {
        var arrX: [[[Cube]]] = []
        let range = 0..<WorldPiece.cubesInRow
        let ridgeLength = Float(Cube.side * WorldPiece.cubesInRow)
        let cs = Float(Cube.side)
        let corr: Float = (ridgeLength - cs) / 2
        for x in range {
            var arrY: [[Cube]] = []
            for y in range {
                var arrZ: [Cube] = []
                for z in range {
                    let cube = Cube(index: (x, y, z))
                    arrZ.append(cube)
                    self.addChildNode(cube)
                    cube.position = SCNVector3(Float(x) * cs - corr, Float(y) * cs - corr, Float(z) * cs - corr)
                }
                arrY.append(arrZ)
            }
            arrX.append(arrY)
        }
        cubes = arrX
    }

    func handleMovement(_ enable: Bool) {
        if enable {
            runAction(moveForwardAction)//, forKey: "moveForward")
        } else {
            removeAllActions()
        }
    }
    
    func getCube(_ x: Int, _ y: Int, _ z: Int) -> Cube {
        return cubes[x][y][z]
    }
    
    func getRow(_ x: Int, _ y: Int) -> [Cube] {
        var retVal: [Cube] = []
        
        for i in 0..<WorldPiece.cubesInRow {
            retVal.append(cubes[x][y][i])
        }
        return retVal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
