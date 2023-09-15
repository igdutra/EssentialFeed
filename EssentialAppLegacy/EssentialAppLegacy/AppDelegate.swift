//
//  AppDelegate.swift
//  EssentialAppLegacy
//
//  Created by Ivo on 14/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /* NOTE UI Testing
     
     Use the below Level to set up UI Tests
     
     */
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
        // Note:
        // Always move these configurations one level above
        
        #if DEBUG
        configuration.delegateClass = DebuggingSceneDelegate.self
        #endif
        
        return configuration
    }
}
