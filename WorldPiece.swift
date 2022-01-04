//
//  WorldPiece.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit
import GameplayKit

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
    var frontContactPlaneNode = SCNNode()
    
    
    override init() {
        super.init()
        
        let pieceSide = CGFloat(Cube.side * WorldPiece.cubesInRow)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceSide, chamferRadius: 0)
        geometry = box
        geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        name = "worldPiece"
        
        initCubes()
        
        let collisionEdge = SCNBox(width: pieceSide, height: pieceSide, length: 0, chamferRadius: 0)
        frontContactPlaneNode = SCNNode(geometry: collisionEdge)
        frontContactPlaneNode.position = SCNVector3Make(0, 0.1, Float(pieceSide / 2))

        frontContactPlaneNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: collisionEdge, options: nil))
        frontContactPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        //frontCollisionPlaneNode.opacity = 0.5
        frontContactPlaneNode.physicsBody?.categoryBitMask = PhysicsCategory.worldPieceFrontEdge.rawValue
        frontContactPlaneNode.physicsBody?.contactTestBitMask = PhysicsCategory.worldUpdtaeTriggerNode.rawValue
        //frontCollisionPlaneNode.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
        frontContactPlaneNode.name = "frontContactPlaneNode"
        frontContactPlaneNode.physicsBody!.mass = 0
        addChildNode(frontContactPlaneNode)
    }
    
    private func initCubes() {
        let noiseMap = createNoiseMap()
//
//        var arrX: [[[Cube]]] = []
//        let range = 0..<WorldPiece.cubesInRow
//        let ridgeLength = Float(Cube.side * WorldPiece.cubesInRow)
//        let cs = Float(Cube.side)
//        let corr: Float = (ridgeLength - cs) / 2
//
//        let slices: [[[Cube]]] = []
//
        
        
        
        
        
        
        
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
//                    if cube.index.0 == 0 {
//                        cube.geometry!.firstMaterial?.diffuse.contents = UIColor.yellow
//                    }
                }
                arrY.append(arrZ)
            }
            arrX.append(arrY)
        }
        cubes = arrX
    }
    
    func createNoiseMap() -> GKNoiseMap {
        let source = GKRidgedNoiseSource(frequency: 0.2, octaveCount: 3, lacunarity: 4.2, seed: 437)
        let noise = GKNoise.init(source)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(5, 5), seamless: false)
        return map
        
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
