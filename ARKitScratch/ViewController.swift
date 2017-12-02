//
//  ViewController.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/02.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
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
        
        tap.reactive.stateChanged
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] in
                let pos = $0.location(in: self.arView)
                let results = self.arView.hitTest(pos, types: .existingPlaneUsingExtent)
                
                if let result = results.first {
                    guard let anchor = result.anchor,
                        let node = self.arView.node(for: anchor) else { return }
                    
                    node.childNodes.forEach {
                        guard let plane = $0.geometry as? SCNPlane else { return }
                        plane.materials.first?.diffuse.contents = UIColor.red
                    }
                }
                
                self.arView.hitTest(pos)
                    .filter { self.virtualObject.childNodes.contains($0.node) }.first?.node.geometry?.materials.first?.diffuse.contents = UIColor.blue
        }
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
        arView.session.delegate = self
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView.session.run(configuration)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let matrix = SCNMatrix4(frame.camera.transform)
        let cameraPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
        let vector = SCNVector3Make(virtualObject.position.x - cameraPosition.x,
                                    virtualObject.position.y - cameraPosition.y,
                                    virtualObject.position.z - cameraPosition.z)
        let angle = atan2f(vector.x, vector.z)
        virtualObject.rotation = SCNVector4Make(0, 1, 0, angle + .pi)
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
