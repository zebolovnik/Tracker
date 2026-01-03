//
//  Tracker.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay?]
}


