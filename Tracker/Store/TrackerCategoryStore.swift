//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 04.01.2026.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>)
}

final class TrackerCategoryStore: NSObject {

    // MARK: - Public

    weak var delegate: TrackerCategoryStoreDelegate?

    var trackersCategory: [TrackerCategory] {
        guard
            let objects = fetchedResultsController?.fetchedObjects
        else { return [] }

        return objects.compactMap { try? getCategories(from: $0) }
    }

    // MARK: - Private

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?

    private var insertedIndexes: Set<IndexPath> = []
    private var deletedIndexes: Set<IndexPath> = []
    private var updatedIndexes: Set<IndexPath> = []

    // MARK: - Init

    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("AppDelegate cast failed")
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
            return
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    func setDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }

    // MARK: - CRUD

    func fetchAllCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request).compactMap { try? getCategories(from: $0) }
    }

    func addCategory(_ category: TrackerCategory) throws {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = category.title
        entity.tracker = NSSet(array: category.trackers.map { mapToCoreData($0) })
        saveContext()
    }

    func deleteCategory(_ category: TrackerCategory) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)

        guard let entity = try context.fetch(request).first else { return }
        context.delete(entity)
        saveContext()
    }

    func updateCategory(oldTitle: String, newTitle: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)

        guard let entity = try context.fetch(request).first else { return }
        entity.title = newTitle
        saveContext()
    }

    // MARK: - Mapping

    private func getCategories(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = coreData.title else {
            throw TrackerStoreError.missingTitle
        }

        let trackers = (coreData.tracker as? Set<TrackerCoreData>)?
            .compactMap { try? createTracker(from: $0) } ?? []

        return TrackerCategory(title: title, trackers: trackers)
    }

    private func mapToCoreData(_ tracker: Tracker) -> TrackerCoreData {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.schedule = tracker.schedule as NSObject
        entity.color = colorDictionary.first(where: { $0.value == tracker.color })?.key ?? "Color1"
        return entity
    }

    private func createTracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = coreData.id,
            let name = coreData.name
        else {
            throw TrackerStoreError.missingTitle
        }

        let color = UIColor(named: coreData.color ?? "") ?? .colorSelected17
        let emoji = coreData.emoji ?? ""
        let schedule = (coreData.schedule as? [WeekDay]) ?? []

        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }

    // MARK: - FRC

    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        frc.delegate = self
        fetchedResultsController = frc

        try? frc.performFetch()
    }

    // MARK: - Save

    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            print("CoreData save error: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
        updatedIndexes.removeAll()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath { insertedIndexes.insert(newIndexPath) }
        case .delete:
            if let indexPath { deletedIndexes.insert(indexPath) }
        case .update:
            if let indexPath { updatedIndexes.insert(indexPath) }
        case .move:
            if let indexPath { deletedIndexes.insert(indexPath) }
            if let newIndexPath { insertedIndexes.insert(newIndexPath) }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories(
            inserted: insertedIndexes,
            deleted: deletedIndexes,
            updated: updatedIndexes
        )
    }
}
