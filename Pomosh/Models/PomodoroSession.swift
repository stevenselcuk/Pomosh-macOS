//
//  PomodoroSession.swift
//  Pomosh
//

import SwiftData
import Foundation

@Model
class PomodoroSession {
    var taskName: String
    var startedAt: Date
    var completedAt: Date?
    var duration: Int
    var wasCompleted: Bool
    var sessionType: String

    init(taskName: String, duration: Int, sessionType: String = "work") {
        self.taskName = taskName
        self.startedAt = Date()
        self.duration = duration
        self.wasCompleted = false
        self.sessionType = sessionType
    }
}
