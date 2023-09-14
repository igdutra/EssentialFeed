//
//  SceneDelegate.swift
//  EssentialAppLegacy
//
//  Created by Ivo on 14/09/23.
//

import UIKit
import CoreData
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let firstVC = UIViewController()
        firstVC.view.backgroundColor = .green
        window.rootViewController = firstVC
        self.window = window
        window.makeKeyAndVisible()
    }
}
