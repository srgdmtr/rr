//
//  World.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit

enum Row: Int {
    case left = 0, centerLeft = 1, centerRight = 2, right = 3
}

class World: SCNNode {
    var pieces: [WorldPiece] = []
    let piecesCount: Int = 7

    private lazy var playerNode = {
        self.parent!.childNode(withName: "player", recursively: false) as! Player
    }()
    
    override init() {
        super.init()
        
        let pieceSide = CGFloat(Cube.side * WorldPiece.cubesInRow)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceSide * CGFloat(piecesCount), chamferRadius: 0)
        self.geometry = box
        self.name = "world"
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.clear

        for i in 0..<piecesCount {
            let worldPiece = WorldPiece()
            worldPiece.delegate = self
            worldPiece.index = i
            addChildNode(worldPiece)
            worldPiece.position = SCNVector3(0 , 0, Float(i) * Float(pieceSide) - Float(pieceSide * CGFloat(piecesCount) / 2) + Float(pieceSide / 2))
            if i == piecesCount - 1 {
                for j in 0..<WorldPiece.cubesInRow {
                    worldPiece.getRow(j, 0).forEach {
                        $0.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                        $0.physicsBody?.categoryBitMask = PhysicsCategory.staticCube.rawValue
                        //$0.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                        //$0.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
                        $0.setColor(.systemOrange)
                        $0.name = "staticCube"
                    }
                }
            } else {
                for j in 0..<WorldPiece.cubesInRow {
                    worldPiece.getRow(j, 0).forEach {
                        if j != 2 {
                            $0.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                            $0.physicsBody?.categoryBitMask = PhysicsCategory.staticCube.rawValue
                            //$0.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                            //$0.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
                            $0.setColor(.systemOrange)
                            $0.name = "staticCube"
                        }
                    }
                }
            }
            
            let c = worldPiece.getCube(0, 2, 0)
            c.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
            c.physicsBody?.categoryBitMask = PhysicsCategory.obstacle.rawValue
            c.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
            //c.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
            c.setColor(.red)
            c.name = "obstacle"
            pieces.append(worldPiece)
        }
    }
    
    func update() {
        if pieces.count == piecesCount + 1 {
            let i = pieces.count - 1
            pieces[i].removeFromParentNode()
            pieces.remove(at: i)
        }
        let firstPos = pieces.first!.position.z
        let worldPiece = WorldPiece()
        for j in 0..<WorldPiece.cubesInRow {
            worldPiece.getRow(j, 0).forEach {
                if j != 2 {
                    $0.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                    $0.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
                    //$0.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
                    //$0.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
                    $0.setColor(.systemOrange)
                    $0.name = "ground"
                }
            }
        }
        
        worldPiece.delegate = self
        pieces.forEach {
            $0.index += 1
        }
        worldPiece.index = 0
        addChildNode(worldPiece)
        worldPiece.position = SCNVector3(0 , 0, firstPos - Float(Cube.side * 4))
        pieces.insert(worldPiece, at: 0)
        
        worldPiece.handleMovement(true)
    }
    
    func tmpSetRoad() {
        
    }
        
    func handleMovement(_ enable: Bool) {
        pieces.forEach {
            $0.handleMovement(enable)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension World: WorldPieceDelegate {
    func playerDidEnterPiece(with index: Int) {

    }
}
