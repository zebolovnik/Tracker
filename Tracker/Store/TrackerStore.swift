//
//  TrackerStore.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import UIKit
import CoreData

class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private var pinnedTrackers: Set<UUID> = []
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            Logger.error("TrackerStore: AppDelegate could not be cast to expected type.")
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.init(context: context)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        let existingTrackers = try context.fetch(fetchRequest)
        let trackerCoreData: TrackerCoreData
        
        if let existingTrackerCoreData = existingTrackers.first {
            trackerCoreData = existingTrackerCoreData
            updateTrackers(trackerCoreData, with: tracker)
            Logger.debug("Трекер \(tracker.name) обновлен в Core Data")
        } else {
            trackerCoreData = TrackerCoreData(context: context)
            updateTrackers(trackerCoreData, with: tracker)
            Logger.debug("Трекер \(tracker.name) добавлен в Core Data")
        }
        let categoryToAdd = try fetchCategory(with: category.title) ?? createNewCategory(with: category.title)
        categoryToAdd.addToTracker(trackerCoreData)
        saveContext()
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)
        return result.compactMap { trackerCoreData in
            do {
                return try createTracker(from: trackerCoreData)
            } catch {
                Logger.error("Ошибка при создании Tracker в TrackerStore: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func pinTracker(id: UUID) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(by: id) else { return }
        if !pinnedTrackers.contains(id) {
            pinnedTrackers.insert(id)
            let originalCategory = trackerCoreData.category?.title
            trackerCoreData.isPinned = true
            trackerCoreData.originalCategory = originalCategory
            try updateTrackerCategory(trackerCoreData, categoryTitle: "Закрепленные")
            saveContext()
        }
    }
    
    func unpinTracker(id: UUID) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(by: id) else { return }
        if pinnedTrackers.contains(id) {
            pinnedTrackers.remove(id)
            if let originalCategory = trackerCoreData.originalCategory {
                try updateTrackerCategory(trackerCoreData, categoryTitle: originalCategory)
            }
            trackerCoreData.isPinned = false
            trackerCoreData.originalCategory = nil
            saveContext()
        }
    }
    
    func fetchPinnedTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isPinned == YES")
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { try? createTracker(from: $0) }
        } catch {
            Logger.error("Ошибка при получении закрепленных трекеров: \(error.localizedDescription)")
            return []
        }
    }
    
    func isTrackerPinned(id: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                return tracker.isPinned
            }
        } catch {
            Logger.error("Ошибка при получении состояния isPinned для трекера \(id): \(error.localizedDescription)")
        }
        return false
    }
    
    func deleteTracker(id: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let trackerToDelete = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "TrackerStoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Трекер с id \(id) не найден"])
        }
        context.perform {
            self.context.delete(trackerToDelete)
            self.saveContext()
        }
    }
    
    private func updateTrackerCategory(_ trackerCoreData: TrackerCoreData, categoryTitle: String) throws {
        let category = try fetchCategory(with: categoryTitle) ?? createNewCategory(with: categoryTitle)
        category.addToTracker(trackerCoreData)
        saveContext()
    }
    
    private func fetchTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(fetchRequest).first
    }
    
    private func updateTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        guard let (colorString, _) = colorDictionary.first(where: { $0.value == tracker.color }) else {
            Logger.error("TrackerStore: Не удалось найти строковое представление для цвета \(tracker.color)")
            assertionFailure("TrackerStore: Не удалось найти строковое представление для цвета \(tracker.color)")
            return
        }
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorString
        trackerCoreData.emoji = tracker.emoji
        Logger.debug("TrackerStore updateTrackers - Исходное schedule перед трансформацией: \(tracker.schedule)")
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
    
    private func createTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id ?? UUID() as UUID?,
              let name = trackerCoreData.name else {
            throw TrackerStoreError.missingTitle
        }
        
        let color: UIColor
        if let colorName = trackerCoreData.color, let uiColor = UIColor(named: colorName) {
            color = uiColor
        } else {
            color = .colorSelected17
        }
        
        let emoji = trackerCoreData.emoji ?? ""
        var schedule: [WeekDay] = []
        if let scheduleData = trackerCoreData.schedule as? [WeekDay?] {
            schedule = scheduleData.compactMap { $0 }
        }
        if schedule.isEmpty {
            Logger.warning("TrackerStore: расписание оказалось пустым после фильтрации.")
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func fetchCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(fetchRequest).first
    }
    
    private func createNewCategory(with title: String) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title.isEmpty ? "Новая категория" : title
        return newCategory
    }
    
    private func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        do {
            try controller.performFetch()
        } catch {
            Logger.error("Failed to fetch trackers: \(error.localizedDescription)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
            Logger.debug("Данные успешно сохранены в Core Data")
        } catch {
            context.rollback()
            Logger.error("Ошибка сохранения в Core Data: \(error.localizedDescription)")
        }
    }
}
