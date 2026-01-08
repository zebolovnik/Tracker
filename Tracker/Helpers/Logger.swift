//
//  Logger.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 06.01.2026.
//

import Foundation
import os.log

final class Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.tracker.app"
    
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let data = OSLog(subsystem: subsystem, category: "Data")
    static let onboarding = OSLog(subsystem: subsystem, category: "Onboarding")
    static let general = OSLog(subsystem: subsystem, category: "General")
    
    static func debug(_ message: String, log: OSLog = .default) {
        #if DEBUG
        print("🔍 [DEBUG] \(message)")
        os_log("%{public}@", log: log, type: .debug, message)
        #endif
    }
    
    static func info(_ message: String, log: OSLog = .default) {
        print("ℹ️ [INFO] \(message)")
        os_log("%{public}@", log: log, type: .info, message)
    }
    
    static func warning(_ message: String, log: OSLog = .default) {
        print("⚠️ [WARNING] \(message)")
        os_log("%{public}@", log: log, type: .default, message)
    }
    
    static func error(_ message: String, log: OSLog = .default) {
        print("❌ [ERROR] \(message)")
        os_log("%{public}@", log: log, type: .error, message)
    }
    
    // Для совместимости со старым кодом
    static func logPrint(_ message: String, category: String = "General") {
        #if DEBUG
        let icon: String
        switch category {
        case "UI": icon = "🖥️"
        case "Data": icon = "💾"
        case "Onboarding": icon = "🚀"
        case "Error": icon = "❌"
        default: icon = "📝"
        }
        print("\(icon) [\(category)] \(message)")
        #endif
    }
}
