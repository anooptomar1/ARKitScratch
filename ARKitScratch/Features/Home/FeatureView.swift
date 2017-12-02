//
//  FeatureView.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/02.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Showcase

final class FeatureView: UIView, ReusableView {
    typealias Model = FeatureModel
    
    @IBOutlet fileprivate weak var titleButton: UIButton!
    
    fileprivate let tapDisposable: ScopedDisposable<SerialDisposable> = .init(.init())
    
    func configure(with model: Model) {
        titleButton.setTitle(model.title, for: .normal)
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        
        tapDisposable.inner.inner = tap.reactive.stateChanged
            .observeValues { _ in
                SceneManager.shared.sceneObserver.send(value: model.scene)
        }
    }
}
