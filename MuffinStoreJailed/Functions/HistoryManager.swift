//
//  HistoryManager.swift
//  PancakeStore
//
//  Created for PancakeStore v1.3.1
//

import Foundation

public struct DowngradeRecord: Codable, Identifiable {
    public var id: UUID
    public let appId: String
    public let bundleId: String
    public let appVersion: String
    public let timestamp: Date
    
    public init(id: UUID = UUID(), appId: String, bundleId: String, appVersion: String, timestamp: Date = Date()) {
        self.id = id
        self.appId = appId
        self.bundleId = bundleId
        self.appVersion = appVersion
        self.timestamp = timestamp
    }
}

public final class HistoryManager: ObservableObject {
    public static let shared = HistoryManager()
    private let storageKey = "pancakestore_downgrade_history"
    
    @Published public var records: [DowngradeRecord] = []
    
    public init() {
        loadHistory()
    }
    
    public func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let list = try? JSONDecoder().decode([DowngradeRecord].self, from: data) else {
            self.records = []
            return
        }
        self.records = list
    }
    
    public func addRecord(appId: String, bundleId: String, appVersion: String) {
        var current = getRawRecords()
        current.removeAll { $0.appId == appId && $0.appVersion == appVersion }
        let item = DowngradeRecord(appId: appId, bundleId: bundleId, appVersion: appVersion, timestamp: Date())
        current.insert(item, at: 0)
        if current.count > 30 {
            current = Array(current.prefix(30))
        }
        if let data = try? JSONEncoder().encode(current) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        DispatchQueue.main.async {
            self.records = current
        }
    }
    
    public func removeRecord(id: UUID) {
        var current = getRawRecords()
        current.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(current) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        DispatchQueue.main.async {
            self.records = current
        }
    }
    
    public func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        DispatchQueue.main.async {
            self.records = []
        }
    }
    
    private func getRawRecords() -> [DowngradeRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let list = try? JSONDecoder().decode([DowngradeRecord].self, from: data) else {
            return []
        }
        return list
    }
}
