//
//  TrackerTestsMocks.swift
//  TrackerTests
//
//  Created by Nikolay Zebolov on 10.01.2026.
//

import UIKit
import CoreData
@testable import Tracker
import XCTest

// MARK: - Моки (наследуются от реальных классов)
final class MockTrackerCategoryStore: TrackerCategoryStore {
    var mockCategories: [TrackerCategory] = []
    var fetchAllCategoriesCalled = false
    
    override var trackersCategory: [TrackerCategory] {
        return mockCategories
    }
    
    override func fetchAllCategories() throws -> [TrackerCategory] {
        fetchAllCategoriesCalled = true
        return mockCategories
    }
}

final class MockTrackerRecordStore: TrackerRecordStore {
    var mockRecords: [TrackerRecord] = []
    var completedDaysCalled = false
    var isRecordExistsCalled = false
    
    override func completedDays(for id: UUID) throws -> [Date] {
        completedDaysCalled = true
        return mockRecords.filter { $0.id == id }.map { $0.date }
    }
    
    override func isRecordExists(id: UUID, date: Date) throws -> Bool {
        isRecordExistsCalled = true
        return mockRecords.contains { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    override func updateRecord(id: UUID, date: Date) throws {
        // Пустая реализация для тестов
        let newRecord = TrackerRecord(id: id, date: date)
        mockRecords.append(newRecord)
    }
    
    override func deleteRecord(id: UUID, date: Date) throws {
        // Пустая реализация для тестов
        mockRecords.removeAll { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}

final class MockTrackerStore: TrackerStore {
    var mockTrackers: [Tracker] = []
    var mockPinnedTrackers: [Tracker] = []
    var addTrackerCalled = false
    var pinTrackerCalled = false
    var unpinTrackerCalled = false
    
    override func fetchPinnedTrackers() -> [Tracker] {
        return mockPinnedTrackers
    }
    
    override func isTrackerPinned(id: UUID) -> Bool {
        return mockPinnedTrackers.contains { $0.id == id }
    }
    
    override func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        addTrackerCalled = true
        mockTrackers.append(tracker)
    }
    
    override func pinTracker(id: UUID) throws {
        pinTrackerCalled = true
        if let tracker = mockTrackers.first(where: { $0.id == id }) {
            mockPinnedTrackers.append(tracker)
        }
    }
    
    override func unpinTracker(id: UUID) throws {
        unpinTrackerCalled = true
        mockPinnedTrackers.removeAll { $0.id == id }
    }
    
    override func deleteTracker(id: UUID) throws {
        mockTrackers.removeAll { $0.id == id }
        mockPinnedTrackers.removeAll { $0.id == id }
    }
}

// MARK: - Хелперы для тестов
extension XCTestCase {
    func createMockTracker(id: UUID = UUID(),
                          name: String = "Test Tracker",
                          color: UIColor = .colorSelected1,
                          emoji: String = "😀",
                          schedule: [WeekDay] = [.monday, .wednesday, .friday]) -> Tracker {
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func createMockTrackerRecord(id: UUID = UUID(), daysAgo: Int = 1) -> TrackerRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return TrackerRecord(id: id, date: date)
    }
}
