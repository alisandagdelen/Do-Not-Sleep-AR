//
//  ViewController.swift
//  Do Not Sleep AR
//
//  Created by alisandagdelen on 8.01.2018.
//  Copyright © 2018 alisandagdelen. All rights reserved.
//

import UIKit
import ARKit
import Each

class GameSceneController: UIViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var timer = Each(1).seconds
    var countdown = 15
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    // MARK: Scene Setup Methods
    
    func setupScene() {
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Action Methods
    
    @IBAction func actPlay(_ sender: UIButton) {
        
        self.setTimer()
        self.addNode()
        self.btnPlay.isEnabled = false
    }
    
    @IBAction func actReset(_ sender: UIButton) {
        
        self.timer.stop()
        self.restoreTimer()
        self.btnPlay.isEnabled = true
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.pause()
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: Node Management Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            if countdown > 0 {
                guard let hit = hitTest.first else { return }
                let results = hit
                let node = results.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                    
                }
            }
        }
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/coffeMug.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: "coffeMug", recursively: false)
        jellyfishNode?.position = SCNVector3(randomNumbers(firstNum: 0, secondNum: 2),randomNumbers(firstNum: -0.5, secondNum: 0.5),randomNumbers(firstNum: -1, secondNum: 1))
        if let jellyfishNode = jellyfishNode {
            self.sceneView.scene.rootNode.addChildNode(jellyfishNode)
        }
    }
    
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2 ,node.presentation.position.y - 0.2 ,node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
    
    // MARK: Utility Methods
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.lblTime.text = String(self.countdown)
            if self.countdown == 0 {
                self.lblTime.text = "YOU LOSE"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        
        self.countdown = 10
        self.lblTime.text = String(self.countdown)
    }
    
}
