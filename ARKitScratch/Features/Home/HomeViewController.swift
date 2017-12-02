//
//  HomeViewController.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/02.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import ReactiveSwift
import Showcase

struct FeatureModel: ReusableModel {
    let title: String
    let scene: Scene
}

final class HomeViewController: UIViewController {
    @IBOutlet fileprivate weak var showcase: Showcase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension HomeViewController {
    func configure() {
        let title: [String] = ["Basic", "Measure", "coming soon", "coming soon"]
        let scenes: [Scene] = [.basic, .measure, .unknown, .unknown]
        let models = zip(title, scenes).map(FeatureModel.init(title:scene:))
        
        showcase.layout.itemSize = .init(width: 300, height: 300)
        showcase.register(byNibName: FeatureView.self)
        showcase.reset(FeatureView.self, models: models)
        
        SceneManager.shared.sceneSignal
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in
                switch $0 {
                case .basic:
                    let vc = BasicViewController.instantiate()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                case .measure:
                    let vc = MeasureViewController.instantiate()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                case .unknown:
                    break
                }
        }
    }
}
