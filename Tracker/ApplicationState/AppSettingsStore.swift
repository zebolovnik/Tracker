//
//  AppSettingsStore.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 05.01.2026.
//

import Foundation

final class AppSettingsStore {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var hasSeenOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: "hasSeenOnboarding")
        }
        set {
            userDefaults.set(newValue, forKey: "hasSeenOnboarding")
        }
    }
}
