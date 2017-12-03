//
//  BasicViewController.swift
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
import ReplayKit

final class BasicViewController: UIViewController {
    @IBOutlet fileprivate weak var arView: ARSCNView!
    @IBOutlet fileprivate weak var broadcastButton: UIButton!
    
    fileprivate var broadcastAVC: RPBroadcastActivityViewController?
    fileprivate var broadcastController: RPBroadcastController?
    fileprivate let virtualObject: SCNNode = .init()
    
    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard(name: "BasicViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        return vc!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureVirtualObject()
        configureArSession()
    }
}

private extension BasicViewController {
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
        
        broadcastButton.reactive.controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                RPBroadcastActivityViewController.load { vc, error in
                    self.broadcastAVC = vc
                    self.broadcastAVC?.delegate = self
                    self.present(self.broadcastAVC!, animated: true, completion: nil)
                }
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

extension BasicViewController: ARSessionDelegate {
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

extension BasicViewController: ARSCNViewDelegate {
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

extension BasicViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        broadcastAVC?.dismiss(animated: true, completion: nil)
        self.broadcastController = broadcastController
    }
}
