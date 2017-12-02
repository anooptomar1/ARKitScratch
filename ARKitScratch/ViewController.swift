//
//  ViewController.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/02.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import ARKit

final class ViewController: UIViewController {
    @IBOutlet fileprivate weak var arView: ARSCNView!
    fileprivate let virtualObject: SCNNode = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureVirtualObject()
        configureArSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arView.session.pause()
    }
}

private extension ViewController {
    func configure() {
        let tap = UITapGestureRecognizer()
        arView.addGestureRecognizer(tap)
    }
    
    func configureVirtualObject() {
        let scene = SCNScene(named: "art.scnassets/engel-1/engel.scn")!
        scene.rootNode.childNodes.forEach { virtualObject.addChildNode($0) }
    }
    
    func configureArSession() {
        arView.scene = SCNScene(named: "art.scnassets/ship.scn")!
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.delegate = self
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView.session.run(configuration)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let geometry = SCNPlane(width: .init(planeAnchor.extent.x), height: .init(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.blue
        
        let planeNode = SCNNode(geometry: geometry)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0)
        
        DispatchQueue.main.async {
            node.addChildNode(planeNode)
            node.addChildNode(self.virtualObject)
        }
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
}
