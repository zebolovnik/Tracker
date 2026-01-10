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
    
    private var mockCategoryStore: MockTrackerCategoryStore!
    private var mockRecordStore: MockTrackerRecordStore!
    private var mockTrackerStore: MockTrackerStore!
    
    override func setUp() {
        super.setUp()
        
        // Создаем моки
        mockCategoryStore = MockTrackerCategoryStore()
        mockRecordStore = MockTrackerRecordStore()
        mockTrackerStore = MockTrackerStore()
        
        // Настраиваем тестовые данные
        setupTestData()
    }
    
    override func tearDown() {
        mockCategoryStore = nil
        mockRecordStore = nil
        mockTrackerStore = nil
        super.tearDown()
    }
    
    private func setupTestData() {
        // Создаем тестовые трекеры
        let tracker1 = createMockTracker(
            id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Пить воду",
            color: .colorSelected1,
            emoji: "💧",
            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        )
        
        let tracker2 = createMockTracker(
            id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
            name: "Бег по утрам",
            color: .colorSelected5,
            emoji: "🏃",
            schedule: [.monday, .wednesday, .friday]
        )
        
        let category = TrackerCategory(
            title: "Здоровье",
            trackers: [tracker1, tracker2]
        )
        
        mockCategoryStore.mockCategories = [category]
        mockTrackerStore.mockTrackers = [tracker1, tracker2]
        
        // Добавляем тестовые записи
        let record = createMockTrackerRecord(
            id: tracker1.id,
            daysAgo: 1
        )
        mockRecordStore.mockRecords = [record]
    }
    
    func testViewControllerLightTheme() {
//        isRecording = true // Раскомментировать для первого запуска
        
        let vc = TrackersViewController()
        
        // Инъекция зависимостей
        vc.trackerCategoryStore = mockCategoryStore
        vc.trackerRecordStore = mockRecordStore
        vc.trackerStore = mockTrackerStore
        
        // Загружаем view
        vc.loadViewIfNeeded()
        
        // Ждем загрузки данных
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        
        // Тест светлой темы
        assertSnapshot(of: vc, as: .image(on: .iPhone13), record: false)
    }
    
    func testViewControllerDarkTheme() {
        let vc = TrackersViewController()
        
        // Инъекция зависимостей
        vc.trackerCategoryStore = mockCategoryStore
        vc.trackerRecordStore = mockRecordStore
        vc.trackerStore = mockTrackerStore
        
        // Загружаем view
        vc.loadViewIfNeeded()
        
        // Ждем загрузки данных
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        
        // Тест темной темы
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: vc, as: .image(on: .iPhone13, traits: traits), record: false)
    }
    
    func testViewControllerShouldFailWhenBackgroundChanges() {
        let vc = TrackersViewController()
        
        // Инъекция зависимостей
        vc.trackerCategoryStore = mockCategoryStore
        vc.trackerRecordStore = mockRecordStore
        vc.trackerStore = mockTrackerStore
        
        // Загружаем view
        vc.loadViewIfNeeded()
        
        // Ждем загрузки данных
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        
        // Первый assert - должен пройти
        assertSnapshot(of: vc, as: .image(on: .iPhone13), record: false)
        
        // Раскомментировать для демонстрации падения теста:
        // vc.view.backgroundColor = .red
        // assertSnapshot(of: vc, as: .image(on: .iPhone13), record: false)
    }
}
