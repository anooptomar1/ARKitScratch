//
//  VideoViewController.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/03.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SpriteKit
import SceneKit
import ARKit

final class VideoViewController: UIViewController {
    @IBOutlet fileprivate weak var arView: ARSCNView!
    
    fileprivate let path: String = "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8"
    fileprivate var vNode: SCNNode?
    
    static func instantiate() -> UIViewController {
        let vc = UIStoryboard(name: "VideoViewController", bundle: nil).instantiateInitialViewController()!
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureArSession()
    }
}

private extension VideoViewController {
    func configureArSession() {
        let scene = SCNScene()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        arView.scene = scene
        arView.delegate = self
        arView.session.delegate = self
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView.session.run(configuration)
    }
    
    func createVideoBox() {
        let scene = SCNScene()
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(1, 0, 15)
        scene.rootNode.addChildNode(cameraNode)
        
        let url = URL(string: path)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        player.play()
        let skScene = SKScene()
        skScene.backgroundColor = .black
        skScene.size = .init(width: 1024, height: 1024)
        
        let skVideoNode = SKVideoNode(avPlayer: player)
        
        skVideoNode.size = .init(width: 1024, height: 1024)
        skVideoNode.position = .init(x: 512, y: 512)
        
        skScene.addChild(skVideoNode)
        
        let boxNode = SCNNode(geometry: SCNBox(width: 4, height: 4, length: 4, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = skScene
        scene.rootNode.addChildNode(boxNode)
        
        arView.scene = scene
        arView.allowsCameraControl = true
        arView.backgroundColor = .black
    }
}

extension VideoViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard vNode == nil else { return }
        let url = URL(string: path)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        let skScene = SKScene()
        skScene.backgroundColor = .black
        skScene.size = .init(width: 1024, height: 1024)
        skScene.scaleMode = .fill
        
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.position = .init(x: skScene.size.width / 2, y: skScene.size.height / 2)
        videoNode.size = CGSize(width: 1024, height: 1024)
        videoNode.play()
        videoNode.zRotation = .pi
        
        skScene.addChild(videoNode)
        let boxNode = SCNNode(geometry: SCNBox(width: 2, height: 2, length: 0.1, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = skScene
        vNode = boxNode
        
        DispatchQueue.main.async {
            node.addChildNode(boxNode)
        }
    }
}

extension VideoViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let node = vNode else { return }
        let matrix = SCNMatrix4(frame.camera.transform)
        let cameraPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
        let vec = SCNVector3(node.position.x - cameraPosition.x,
                             node.position.y - cameraPosition.y,
                             node.position.z - cameraPosition.z)
        let angle = atan2f(vec.x, vec.z)
        node.rotation = SCNVector4Make(0, 1, 0, angle + .pi)
    }
}
