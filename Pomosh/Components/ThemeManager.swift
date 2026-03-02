//
//  ThemeManager.swift
//  Pomosh
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case neon = "Neon"
    case forest = "Forest"
    case ocean = "Ocean"
    case sunset = "Sunset"

    var id: String { rawValue }

    var ringWorkColors: [Color] {
        switch self {
        case .neon:
            return [Color(red: 0.26, green: 0.76, blue: 0.97), Color(red: 0.36, green: 0.07, blue: 0.97)]
        case .forest:
            return [Color(red: 0.13, green: 0.55, blue: 0.13), Color(red: 0.0, green: 0.39, blue: 0.0)]
        case .ocean:
            return [Color(red: 0.0, green: 0.45, blue: 0.85), Color(red: 0.25, green: 0.88, blue: 0.82)]
        case .sunset:
            return [Color(red: 1.0, green: 0.34, blue: 0.13), Color(red: 0.91, green: 0.12, blue: 0.39)]
        }
    }

    var ringBreakColors: [Color] {
        switch self {
        case .neon:
            return [Color(red: 1.0, green: 0.0, blue: 0.46), Color(red: 0.99, green: 0.93, blue: 0.13)]
        case .forest:
            return [Color(red: 0.56, green: 0.93, blue: 0.56), Color(red: 0.13, green: 0.55, blue: 0.13)]
        case .ocean:
            return [Color(red: 0.0, green: 0.73, blue: 0.94), Color(red: 0.0, green: 0.45, blue: 0.85)]
        case .sunset:
            return [Color(red: 1.0, green: 0.65, blue: 0.0), Color(red: 1.0, green: 0.34, blue: 0.13)]
        }
    }

    var accentColor: Color {
        switch self {
        case .neon:   return Color(red: 0.26, green: 0.76, blue: 0.97)
        case .forest: return Color(red: 0.13, green: 0.55, blue: 0.13)
        case .ocean:  return Color(red: 0.0, green: 0.45, blue: 0.85)
        case .sunset: return Color(red: 1.0, green: 0.34, blue: 0.13)
        }
    }

    var icon: String {
        switch self {
        case .neon:   return "⚡"
        case .forest: return "🌲"
        case .ocean:  return "🌊"
        case .sunset: return "🌅"
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.neon.rawValue
        currentTheme = AppTheme(rawValue: saved) ?? .neon
    }
}
