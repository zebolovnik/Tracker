//
//  TrackerStoreError.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 04.01.2026.
//

import Foundation

enum TrackerStoreError: Error {
    case missingTitle
    case missingColor
    case invalidSchedule
}
