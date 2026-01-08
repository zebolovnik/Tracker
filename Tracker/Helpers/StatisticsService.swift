//
//  StatisticsService.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 09.01.2026.
//

import Foundation

protocol StatisticsServiceDelegate: AnyObject {
    func statisticsDidUpdate()
}

final class StatisticsService {
    static let shared = StatisticsService()
    
    private let recordStore: TrackerRecordStore
    weak var delegate: StatisticsServiceDelegate?
    
    init(recordStore: TrackerRecordStore = TrackerRecordStore()) {
        self.recordStore = recordStore
    }
    
    func getFinishedTrackersCount() -> Int {
        return recordStore.getFinishedTrackersCount()
    }
    
    func notifyUpdate() {
        delegate?.statisticsDidUpdate()
    }
}
