//
//  PerlinWorldPiece.swift
//  gggggg
//
//  Created by Mishunin on 03.01.2022.
//

import SceneKit
import GameplayKit


class PerlinWorldPiece: SCNNode {
    static let width: Int = 7
    static let length: Int = 21
    
    var noiseMarks: [Float] = []
    
    static var index: Int = -1
    var cubes: [[Cube]] = []
    let moveForwardAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3(0, 0, 10), duration: 1))
    var frontContactPlaneNode = SCNNode()
    
    func createNoiseMap() -> GKNoiseMap {
        let frequency = Double.random(in: 1.1...1.6)
        let octaveCount = Int.random(in: 1..<3)
        let persistence = Double.random(in: 1.3...2.5)
        let lacunarity = Double.random(in: 1.1...2.2)
        let seed = Int32.random(in: 1...Int32(PerlinWorldPiece.width))
        
        let source = GKPerlinNoiseSource(frequency: frequency, octaveCount: 1, persistence: 1, lacunarity: lacunarity, seed: seed)
        let noise = GKNoise.init(source)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(Int32(PerlinWorldPiece.width), Int32(PerlinWorldPiece.length)), seamless: true)
        return map
    }
    
    override init() {
        super.init()
        PerlinWorldPiece.index += 1
        
        let pieceSide = CGFloat(Cube.side * PerlinWorldPiece.width)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceSide, chamferRadius: 0)
        geometry = box
        geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        name = "worldPiece"
        
        initAmplitydes()
        initWorldPiece()
        addWorldUpdateTriggerPlane()
    }
    
    private func initAmplitydes() {
        let step: Float = 2.0 / Float(PerlinWorldPiece.width - 1)
        
        for i in 0..<PerlinWorldPiece.width {
            noiseMarks.append(step * Float(i))
        }
    }
    
    private func initWorldPiece() {
        
        let ridgeLength = Float(Cube.side * PerlinWorldPiece.width)
        let cs = Float(Cube.side)
        let corr: Float = (ridgeLength - cs) / 2
        
        if PerlinWorldPiece.index == 5 {
            for x in 0 ..< PerlinWorldPiece.width {
                for z in 0 ..< PerlinWorldPiece.length {
                    let cube = Cube(index: (x, 0, z))
                    self.addChildNode(cube)
                    cube.name = "perlinStaticCube"
                    cube.position = SCNVector3(Float(x) * cs - corr, -corr, Float(z) * cs - corr)
                    cube.setColor(.orange)
                    cube.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                    cube.physicsBody?.categoryBitMask = PhysicsCategory.staticCube.rawValue
                    cube.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue
                    cube.physicsBody?.angularVelocityFactor = SCNVector3(0, 0, 0)
                    cube.physicsBody?.mass = 100
                    
                }
            }
        } else {
            let noiseMap = createNoiseMap()
            let rc = UIColor.random()
            
            let centralLinesIndexes = [(PerlinWorldPiece.width / 2) - 1, PerlinWorldPiece.width / 2, (PerlinWorldPiece.width / 2) + 1]
            var emptyLines: [Int] = []
            centralLinesIndexes.forEach {
                if Bool.random() {
                    emptyLines.append($0)
                }
            }
            
            for x in 0 ..< PerlinWorldPiece.width {
                for z in 0 ..< PerlinWorldPiece.length {
                    let location = vector2(Int32(x), Int32(z))
                    if !emptyLines.contains(x) {
                        let value = noiseMap.value(at: location)
                        let closest = noiseMarks.enumerated().min( by: { abs($0.1 - value) < abs($1.1 - value) } )!
                        let y = closest.offset
                        let cube = Cube(index: (x, y, z))
                        self.addChildNode(cube)
                        cube.position = SCNVector3(Float(x) * cs - corr, Float(y) * cs - corr, Float(z) * cs - corr)
                        cube.setColor(rc)
                        cube.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                        cube.physicsBody?.categoryBitMask = PhysicsCategory.staticCube.rawValue
                        cube.name = "perlinStaticCube"
                        
                        if y > 0 {
                            for i in 0..<y {
                                let cube = Cube(index: (x, i, z))
                                self.addChildNode(cube)
                                cube.position = SCNVector3(Float(x) * cs - corr, Float(i) * cs - corr, Float(z) * cs - corr)
                                cube.setColor(.black)
                                cube.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
                                cube.physicsBody?.categoryBitMask = PhysicsCategory.staticCube.rawValue
                                cube.name = "perlinStaticCube"
                            }
                        }
                    }
                }
            }
            //tmp
            let box = SCNBox(width: CGFloat(Cube.side), height: CGFloat(Cube.side), length: CGFloat(Cube.side), chamferRadius: 0)
            let enemy = Cube(index: (-1, -1, -1))
            self.addChildNode(enemy)
            enemy.geometry = box
            enemy.name = "enemy"
            enemy.geometry?.firstMaterial?.shininess = 1.0
            enemy.position =  SCNVector3(Float(Int.random(in: 0..<PerlinWorldPiece.width)) * cs - corr, Float(6) * cs - corr, Float(Int.random(in: 0..<PerlinWorldPiece.length)) * cs - corr)
            enemy.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: box, options: nil))
            enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
            enemy.physicsBody?.collisionBitMask = PhysicsCategory.player.rawValue | PhysicsCategory.staticCube.rawValue
            //enemy.physicsBody?.contactTestBitMask = PhysicsCategory.staticCube.rawValue
            enemy.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            //self.physicsBody?.damping = 0
            physicsBody?.velocity = SCNVector3(0, 0, 0)
            enemy.physicsBody?.mass = 60
        }
    }

    
    func handleMovement(_ enable: Bool) {
        if enable {
            runAction(moveForwardAction)//, forKey: "moveForward")
        } else {
            removeAllActions()
        }
    }
    
    private func addWorldUpdateTriggerPlane() {
        let pieceSide = CGFloat(Cube.side * PerlinWorldPiece.width)
        let collisionEdge = SCNBox(width: pieceSide, height: pieceSide, length: 0.1, chamferRadius: 0)
        frontContactPlaneNode = SCNNode(geometry: collisionEdge)
        frontContactPlaneNode.position = SCNVector3Make(0, 0.1, Float(pieceSide / 2))

        frontContactPlaneNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: collisionEdge, options: nil))
        frontContactPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
//        frontContactPlaneNode.opacity = 0.6
        frontContactPlaneNode.physicsBody?.categoryBitMask = PhysicsCategory.worldPieceFrontEdge.rawValue
        frontContactPlaneNode.physicsBody?.contactTestBitMask = PhysicsCategory.worldUpdtaeTriggerNode.rawValue
        frontContactPlaneNode.name = "frontContactPlaneNode"
        frontContactPlaneNode.physicsBody!.mass = 0
        addChildNode(frontContactPlaneNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
