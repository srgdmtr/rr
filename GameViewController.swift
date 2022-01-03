//
//  GameViewController.swift
//  gggggg
//
//  Created by Mishunin on 19.12.2021.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var gameScene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnView = view as! SCNView
        //scnView.delegate = self
        gameScene = GameScene(currentview: scnView)
        gameScene.sceneView.delegate = self
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        gameScene.update()
    }
    
}
