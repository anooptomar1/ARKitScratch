//
//  MeasureViewController.swift
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

final class MeasureViewController: UIViewController {
    @IBOutlet fileprivate weak var arView: ARSCNView!
    fileprivate var startNode: SCNNode?
    fileprivate var endNode: SCNNode?
    
    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard(name: "MeasureViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        return vc!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension MeasureViewController {
    func configure() {
        let tap = UITapGestureRecognizer()
        arView.addGestureRecognizer(tap)
    }
    
    func configureArSession() {
        arView.scene = SCNScene(named: "art.scnassets/ship.scn")!
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arView.session.run(configuration)
    }
}
