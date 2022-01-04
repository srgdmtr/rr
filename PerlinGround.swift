//
//  PerlinGround.swift
//  gggggg
//
//  Created by Mishunin on 03.01.2022.
//

import SceneKit
import GameplayKit


class PWorldPiece: SCNNode {
    enum SliceAxis {
        case horizontal, vertical
    }
    var index: Int = 0
    var cubes: [[Cube]] = []
    let moveForwardAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3(0, 0, 10), duration: 1))
    var frontContactPlaneNode = SCNNode()
    
    func createNoiseMap() -> GKNoiseMap {
        let source = GKRidgedNoiseSource(frequency: 0.2, octaveCount: 3, lacunarity: 4.2, seed: 437)
        let noise = GKNoise.init(source)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(5, 5), seamless: false)
        return map
        
    }
    
    override init() {
        super.init()
        
        
        
        
        
        
        let pieceSide = CGFloat(Cube.side * WorldPiece.cubesInRow)
        let box = SCNBox(width: pieceSide, height: pieceSide, length: pieceSide, chamferRadius: 0)
        geometry = box
        geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        name = "worldPiece"
        
        initCubes()
        
    }
    
    private func initCubes() {
        let noiseMap = createNoiseMap()
        var arrX: [[Cube]] = []
        for x in 0 ..< 5 {
            var arrY: [Cube] = []
            for y in 0 ..< 5 {
                let range = 0..<WorldPiece.cubesInRow
                let ridgeLength = Float(Cube.side * WorldPiece.cubesInRow)
                let cs = Float(Cube.side)
                let corr: Float = (ridgeLength - cs) / 2
                let cube = Cube(index: (0, 0, 0))
                arrY.append(cube)
                self.addChildNode(cube)
                
                let location = vector2(Int32(y), Int32(x))
                let terrainHeight = noiseMap.value(at: location)
                
                cube.position = SCNVector3(Float(x) * cs - corr, 0, Float(y) * cs - corr)
                
                if terrainHeight < 0 {
                    cube.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                } else {
                    cube.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                }
            }
        }
    }

  
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
