//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let appSettingsStore = AppSettingsStore()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
//        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        let hasSeenOnboarding = appSettingsStore.hasSeenOnboarding
        let rootViewController: UIViewController
        
        if hasSeenOnboarding {
            rootViewController = TabBarViewController()
        } else {
            let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            rootViewController = onboardingViewController
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
