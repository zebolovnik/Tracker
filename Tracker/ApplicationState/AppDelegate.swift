//
//  AppDelegate.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DaysValueTransformer.register()
        window = UIWindow()
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    func checkAndRemoveOldPersistentStore() {
        if let store = persistentContainer.persistentStoreCoordinator.persistentStores.first {
            let storeURL = store.url
            if let storeURL = storeURL {
                do {
                    try FileManager.default.removeItem(at: storeURL)
                    Logger.logPrint("Старый persistent store удален.", category: "Data")
                } catch {
                    Logger.logPrint("Ошибка удаления старого persistent store: \(error)", category: "Error")
                }
            }
        } else {
            Logger.logPrint("Не удалось найти persistent store.", category: "Error")
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
}
