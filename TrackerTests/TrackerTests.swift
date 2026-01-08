//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Nikolay Zebolov on 22.12.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        
        assertSnapshot(of: vc, as: .image)
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(of: vc, as:.image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDarkTheme() {
        let vc = TrackersViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
