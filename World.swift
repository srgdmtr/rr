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
    var pieces: [PerlinWorldPiece] = []
    let piecesCount: Int = 6

    private lazy var playerNode = {
        self.parent!.childNode(withName: "player", recursively: false) as! Player
    }()
    
    override init() {
        super.init()
        
        let pieceSide = CGFloat(Cube.side * PerlinWorldPiece.width)
        let pieceLength = CGFloat(Cube.side * PerlinWorldPiece.length)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceLength * CGFloat(piecesCount), chamferRadius: 0)
        self.geometry = box
        self.name = "world"
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.clear

        for i in 0..<piecesCount {
            let worldPiece = PerlinWorldPiece()
            addChildNode(worldPiece)
            worldPiece.position = SCNVector3(0 , 0, Float(i) * Float(pieceLength) - Float(pieceLength * CGFloat(piecesCount) / 2) + Float(pieceLength / 2))
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
        let worldPiece = PerlinWorldPiece()
        addChildNode(worldPiece)
        worldPiece.position = SCNVector3(0 , 0, firstPos - Float(Cube.side * PerlinWorldPiece.length))
        pieces.insert(worldPiece, at: 0)
        
        worldPiece.handleMovement(true)
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

