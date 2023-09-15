//
//  SceneDelegate.swift
//  EssentialAppLegacy
//
//  Created by Ivo on 14/09/23.
//

import UIKit
import CoreData
import EssentialFeed

struct Delegate: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        print("print")
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let feed = makeFeedViewController(delegate: Delegate(), title: "Feed")
        let root = UINavigationController(rootViewController: feed)
        
        window.rootViewController = root
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "LegacyFeed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
