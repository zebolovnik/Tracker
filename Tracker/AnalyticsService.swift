//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 07.01.2026.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "09459db6-51fd-4a01-a7d0-3f45c8ceea98") else {
            print("ANALYTICS ERROR: Failed to create AppMetrica configuration")
            return
        }
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params: [String: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("ANALYTICS ERROR: \(error.localizedDescription)")
        })
    }
    
    enum EventType: String {
        case open
        case close
        case click
    }
    
    enum Screen: String {
        case main = "Main"
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
    
    func reportScreenOpen(_ screen: Screen) {
        let params: [String: Any] = [
            "event": EventType.open.rawValue,
            "screen": screen.rawValue
        ]
        report(event: EventType.open.rawValue, params: params)
    }
    
    func reportScreenClose(_ screen: Screen) {
        let params: [String: Any] = [
            "event": EventType.close.rawValue,
            "screen": screen.rawValue
        ]
        report(event: EventType.close.rawValue, params: params)
    }
    
    func reportClick(screen: Screen, item: Item) {
        let params: [String: Any] = [
            "event": EventType.click.rawValue,
            "screen": screen.rawValue,
            "item": item.rawValue
        ]
        report(event: EventType.click.rawValue, params: params)
    }
}
