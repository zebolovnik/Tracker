//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 05.01.2026.
//

import Foundation
import CoreData

typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    var selectedCategory: String?
    
    var onCategoriesUpdated: Binding<[String]>?
    var onError: Binding<String?>?
    
    private let categoryStore: TrackerCategoryStore
    private var categories: [String] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore() ) {
        self.categoryStore = categoryStore
        categoryStore.setDelegate(self)
        loadCategories()
    }
    
    func addCategory(_ category: String) {
        let newCategory = TrackerCategory(title: category, trackers: [])
        do {
            try categoryStore.addCategory(newCategory)
        } catch {
            Logger.error("CategoryViewModel - Ошибка добавления категории: \(error.localizedDescription)")
            onError?("CategoryViewModel - Ошибка добавления категории: \(error.localizedDescription)")
        }
    }
    
    func getCategories() -> [String] {
        return categories
    }
    
    func isCategorySelected(_ category: String) -> Bool {
        return category == selectedCategory
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func deleteCategory(_ category: String) {
        do {
            let categoryToDelete = TrackerCategory(title: category, trackers: [])
            try categoryStore.deleteCategory(categoryToDelete)
            loadCategories()
        } catch {
            Logger.error("CategoryViewModel - Ошибка удаления категории: \(error.localizedDescription)")
            onError?("CategoryViewModel - Ошибка удаления категории: \(error.localizedDescription)")
        }
    }
    
    private func loadCategories() {
        do {
            let storedCategories = try categoryStore.fetchAllCategories()
            categories = storedCategories.map { $0.title }
        } catch {
            Logger.error("CategoryViewModel - Ошибка загрузки категорий: \(error.localizedDescription)")
        }
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>) {
        loadCategories()
    }
}
