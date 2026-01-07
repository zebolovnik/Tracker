//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 07.01.2026.
//

import Foundation

enum TrackerFilterType: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case trackersToday = "Трекеры на сегодня"
    case completed = "Завершённые"
    case notCompleted = "Незавершённые"
    
    static func from(rawValue: String) -> TrackerFilterType? {
        return TrackerFilterType(rawValue: rawValue)
    }
}
