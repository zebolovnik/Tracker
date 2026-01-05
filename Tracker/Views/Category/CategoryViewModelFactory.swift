//
//  CategoryViewModelFactory.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 05.01.2026.
//

import Foundation

final class CategoryViewModelFactory {
    static func createCategoryViewModel() -> CategoryViewModel {
        let categoryStore = TrackerCategoryStore()
        return CategoryViewModel(categoryStore: categoryStore)
    }
}
