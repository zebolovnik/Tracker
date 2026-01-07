//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 07.01.2026.
//

import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case trackersToday = "Трекеры на сегодня"
    case completed = "Завершённые"
    case notCompleted = "Незавершённые"
    
    static func from(rawValue: String) -> TrackerFilter? {
        return TrackerFilter(rawValue: rawValue)
    }
}
