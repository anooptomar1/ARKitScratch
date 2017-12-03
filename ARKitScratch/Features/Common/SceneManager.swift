//
//  SceneManager.swift
//  ARKitScratch
//
//  Created by Yuya Horita on 2017/12/02.
//  Copyright © 2017 Yuya Horita. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum Scene {
    case basic
    case measure
    case video
    case unknown
}

final class SceneManager {
    static let shared: SceneManager = .init()
    let (sceneSignal, sceneObserver) = Signal<Scene, NoError>.pipe()
    
    private init() {}
}
