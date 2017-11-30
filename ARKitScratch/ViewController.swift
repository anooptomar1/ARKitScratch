//
//  ViewController.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/11/25.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else { return }
        let intensity: CGFloat
        if let lightEstimate = frame.lightEstimate {
            intensity = lightEstimate.ambientIntensity / 400
        } else {
            intensity = 2
        }
    }
    
    // This is a delegate method to add content to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: .init(planeAnchor.extent.x), height: .init(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = .init(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 0.25
        
        // Here, content(planeNode) is added as a child of node corresponding to the anchor.
        // Then, ARSCNView class automatically moves it as ARKit refines its estimated of the plane's position and extent.
        node.addChildNode(planeNode)
        
        let objectNode = SCNNode()
        let shipScene = SCNScene(named: "art.acnassets/ship.scn")
        shipScene?.rootNode.childNodes.forEach {
            $0.geometry?.firstMaterial?.lightingModel = .physicallyBased
            objectNode.addChildNode($0)
        }
        
        DispatchQueue.main.async {
            node.addChildNode(objectNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else { return }
        planeNode.simdPosition = .init(planeAnchor.center.x, 0, planeAnchor.center.z)
        plane.width = .init(planeAnchor.extent.x)
        plane.height = .init(planeAnchor.extent.z)
    }
}
