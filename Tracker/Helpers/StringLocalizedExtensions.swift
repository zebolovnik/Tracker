//
//  StringLocalizedExtensions.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 07.01.2026.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "Localized string")
    }
}
