//
//  PomodoroTask.swift
//  Pomosh
//

import SwiftData
import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case backlog    = "Backlog"
    case inProgress = "In Progress"
    case blocked    = "Blocked"
    case done       = "Done"

    var icon: String {
        switch self {
        case .backlog:    return "circle"
        case .inProgress: return "flame"
        case .blocked:    return "exclamationmark.octagon"
        case .done:       return "checkmark.circle.fill"
        }
    }

    var sortPriority: Int {
        switch self {
        case .inProgress: return 0
        case .backlog:    return 1
        case .blocked:    return 2
        case .done:       return 3
        }
    }
}

@Model
class PomodoroTask {
    var uid: String?
    var title: String
    var notes: String
    var workDuration: Int
    var breakDuration: Int
    var cycles: Int
    var statusRaw: String
    var createdAt: Date
    var completedAt: Date?
    var pomodorosCompleted: Int
    var sortOrder: Int

    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .backlog }
        set { statusRaw = newValue.rawValue }
    }

    var dragID: String {
        uid ?? "\(Int(createdAt.timeIntervalSince1970))"
    }

    /// Total seconds invested in this task (completed pomodoros × work duration)
    var totalSecondsSpent: Int {
        pomodorosCompleted * workDuration
    }

    /// Human-readable time: "45min" if < 1h, "1h 20min" or "2h" if ≥ 1h
    var timeSpentDisplay: String {
        let total = totalSecondsSpent
        guard total > 0 else { return "" }
        let minutes = total / 60
        if minutes < 60 {
            return "\(minutes)min"
        } else {
            let hours = minutes / 60
            let rem   = minutes % 60
            return rem == 0 ? "\(hours)h" : "\(hours)h \(rem)min"
        }
    }

    init(title: String, notes: String = "") {
        self.uid = UUID().uuidString
        self.title = title
        self.notes = notes
        self.workDuration = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
        self.breakDuration = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
        self.cycles = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5
        self.statusRaw = TaskStatus.backlog.rawValue
        self.createdAt = Date()
        self.pomodorosCompleted = 0
        self.sortOrder = 0
    }
}
