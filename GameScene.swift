//
//  GameScene.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import SceneKit
import SpriteKit


public enum PhysicsCategory: Int {
    case player = 1
    case worldUpdtaeTriggerNode = 2
    
    case staticCube = 4
    
    case worldPiece = 8
    case worldPieceFrontEdge = 16
    
    case ground = 32
    
    case world = 64
    case obstacle = 128
    case enemy = 256
    case shoot = 512
}


class GameScene: SCNScene, SCNPhysicsContactDelegate {
    var sceneView: SCNView!
    var overlay: OverlayScene!
    let player = Player()
    let world = World()
    let cameraNode = SCNNode()
    var worldUpdtaeTriggerNode = WorldUpdtaeTriggerNode()
            
    init(currentview view: SCNView) {
        super.init()
        
        physicsWorld.gravity = SCNVector3Make(0, -100, 0)
        physicsWorld.contactDelegate = self
        
        sceneView = view
        sceneView.bounds.size = view.bounds.size
        sceneView.scene = self
        sceneView.debugOptions = SCNDebugOptions.showPhysicsShapes
        sceneView.debugOptions = SCNDebugOptions.showBoundingBoxes
        
        addOverlay()
        setContents()
        
        sceneView.isPlaying = true
    }
    
    private func setContents() {
        //sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.backgroundColor = .blue
        
        setupLight()
        addGround()
        
        rootNode.addChildNode(world)
        world.addChildNode(player)
        
        let pieceSide = Float(Cube.side * WorldPiece.cubesInRow)
        let lenght = pieceSide * Float(world.piecesCount)
        let c = world.pieces[world.pieces.count - 1].getCube(0, 0, 0)
        player.position = SCNVector3(x: c.position.x, y: -pieceSide / 2 + Float(Cube.side / 2) + Float(Cube.side), z: lenght / 2 - Float(Cube.side / 2))
        
        world.addChildNode(worldUpdtaeTriggerNode)
        worldUpdtaeTriggerNode.position = SCNVector3(0, 0, player.presentation.position.z + Float(Cube.side * 3))
        
        cameraNode.camera = SCNCamera()
        world.addChildNode(cameraNode)
        cameraNode.camera?.zFar = 500
        cameraNode.position = SCNVector3(x: 0, y: Float(Cube.side) * 3, z: player.position.z + Float(Cube.side * 4))
        cameraNode.eulerAngles.x = -.pi / 6

        
        world.handleMovement(true)
        
    }
    
    func update() {

    }
    
    private func addOverlay() {
        overlay = OverlayScene(size: sceneView.bounds.size)
        overlay.scaleMode = SKSceneScaleMode.fill
        sceneView.overlaySKScene = overlay
        overlay.overlaySceneDelegate = self
    }
    
    private func setupLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 50, z: 20)
        rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        rootNode.addChildNode(ambientLightNode)
    }
    
    private func addGround() {
        let groundBox = SCNBox(width: CGFloat(Cube.side * 400), height: 1, length: CGFloat(Cube.side * 160), chamferRadius: 0)
        let groundNode = SCNNode(geometry: groundBox)
        groundNode.position = SCNVector3Make(0, -Float(Cube.side * WorldPiece.cubesInRow) / 2 - 1 / 2, 0)
        //groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: groundBox, options: nil))
        //groundNode.physicsBody?.restitution = 0.0
        //groundNode.physicsBody?.friction = 1.0
//        groundNode.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
//        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
//        groundNode.physicsBody?.friction = 0
        groundNode.name = "ground"
        rootNode.addChildNode(groundNode)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodes = [contact.nodeA, contact.nodeB]
        
        if let pbni = nodes.firstIndex(where: {
            $0.physicsBody?.categoryBitMask == PhysicsCategory.worldUpdtaeTriggerNode.rawValue
        }) {
            let contactNode = nodes[pbni == 0 ? 1 : 0]
            if contactNode.physicsBody?.categoryBitMask == PhysicsCategory.worldPieceFrontEdge.rawValue {
                contactNode.physicsBody = nil
                if (contactNode.parent as? WorldPiece) != nil {
                    self.world.update()
                }
            }
        }
        
        if let pi = nodes.firstIndex(where: {
            $0.physicsBody?.categoryBitMask == PhysicsCategory.player.rawValue
        }) {
            let playerNode = nodes[pi] as! Player
            let contactNode = nodes[pi == 0 ? 1 : 0]
            switch contactNode.physicsBody!.categoryBitMask {
                case PhysicsCategory.obstacle.rawValue:
                    print("\(playerNode.name) : \(playerNode.categoryBitMask) : \(playerNode.presentation.convertPosition(SCNVector3(0.5, 0.5, 0.5), to: rootNode))")
                    print("\(contactNode.name) : \(contactNode.categoryBitMask) : \(contactNode.presentation.convertPosition(SCNVector3(0.5, 0.5, 0.5), to: rootNode))")
                    
                  
                    let playerPos = playerNode.presentation.convertPosition(SCNVector3(0.5, 0.5, 0.5), to: self.world)
                    let nodePos = contactNode.presentation.convertPosition(SCNVector3(0.5, 0.5, 0.5), to: self.world)
                    let r = (0.6844 * 1000).rounded() / 1000
                    
                    let pym = (playerPos.y * 1000).rounded() / 1000
                    let nym = (nodePos.y * 1000).rounded() / 1000
                    
                    let dx = (pym - nym).magnitude
                    
                    let dy = (playerPos.y - nodePos.y).magnitude
                    let dz = playerPos.z - nodePos.z
                    
                    if dz <= Float(Cube.side) && dx < 0.1 && dy < Float(Cube.side / 2) {
                        contactNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                        self.world.pieces.forEach {
                            $0.handleMovement(false)
                        }
                        endGame()
                    }
                    
                    
                   
                    
            default :
                break
            }
            
        }
    }
    
    func endGame() {
        sceneView.isPlaying = false
        overlay.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.overlay.view?.gestureRecognizers?.forEach {
                $0.isEnabled = false
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: OverlaySceneDelegate {
    func didSwiped(_ direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
            case .left:
                player.moveTo(.left)
            case .down:
                print("")
            case .right:
                player.moveTo(.right)
            case .up:
                player.jump()
            default:
                break
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1.0), green: CGFloat.random(in: 0...1.0), blue: CGFloat.random(in: 0...1.0), alpha: 1.0)
    }
}
