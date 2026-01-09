//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 04.01.2026.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        Logger.debug("DaysValueTransformer - Начальное значение \(String(describing: value))")
        
        guard let days = value as? [WeekDay?] else {
            Logger.warning("DaysValueTransformer - Возвращаю nil так как не подходящее значение value: \(String(describing: value))")
            return nil
        }
        let filteredDays = days.compactMap { $0 }
        
        if filteredDays.isEmpty {
        } else {
            Logger.debug("DaysValueTransformer - массив не пуст, сохраняем данные.")
        }
        
        do {
            let encodedData = try JSONEncoder().encode(filteredDays) as NSData
            return encodedData as NSData
        } catch {
            Logger.error("DaysValueTransformer - Ошибка кодирования: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            Logger.error("DaysValueTransformer - scheduleData не NSData - возвращаю nil")
            return nil
        }
        if let jsonString = String(data: data as Data, encoding: .utf8) {
            Logger.debug("DaysValueTransformer - JSON строка: \(jsonString)")
        } else {
            Logger.error("DaysValueTransformer - не удалось преобразовать в строку")
        }
        do {
            let decodedDays = try JSONDecoder().decode([WeekDay].self, from: data as Data)
            return decodedDays
        } catch {
            Logger.error("DaysValueTransformer - Ошибка декодирования: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
