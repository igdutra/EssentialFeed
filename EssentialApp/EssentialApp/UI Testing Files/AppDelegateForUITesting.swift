//
//  AppDelegateForUITesting.swift
//  EssentialApp
//
//  Created by Ivo on 26/04/23.
//

import UIKit

//@main
class AppDelegateForUITesting: UIResponder, UIApplicationDelegate {
    
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
