//
//  StatsView.swift
//  Pomosh
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroSession.startedAt, order: .reverse) private var sessions: [PomodoroSession]
    @Binding var currentPage: Int

    private var completedToday: Int {
        let calendar = Calendar.current
        return sessions.filter {
            $0.wasCompleted && $0.sessionType == "work" && calendar.isDateInToday($0.startedAt)
        }.count
    }

    private var completedThisWeek: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let startOfWeek = calendar.date(from: components) ?? Date()
        return sessions.filter {
            $0.wasCompleted && $0.sessionType == "work" && $0.startedAt >= startOfWeek
        }.count
    }

    private var last7DaysData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return (0..<7).reversed().map { offset -> (String, Int) in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let count = sessions.filter {
                $0.wasCompleted && $0.sessionType == "work" &&
                calendar.isDate($0.startedAt, inSameDayAs: date)
            }.count
            return (formatter.string(from: date), count)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Stats")
                    .font(.custom("Space Mono Regular", size: 18))

                HStack(spacing: 12) {
                    StatCard(value: completedToday, label: "Today")
                    StatCard(value: completedThisWeek, label: "This Week")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Last 7 Days")
                        .font(.custom("Space Mono Regular", size: 11))
                        .opacity(0.6)

                    Chart(last7DaysData, id: \.day) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Pomodoros", item.count)
                        )
                        .foregroundStyle(Color("Neon").gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 90)
                    .chartYAxis(.hidden)
                }

                if sessions.isEmpty {
                    Text("No sessions yet.\nStart your first Pomodoro!")
                        .font(.custom("Space Mono Regular", size: 11))
                        .opacity(0.5)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recent")
                            .font(.custom("Space Mono Regular", size: 11))
                            .opacity(0.6)

                        ForEach(sessions.prefix(5)) { session in
                            HStack {
                                Text(session.taskName.isEmpty ? "Unnamed session" : session.taskName)
                                    .font(.custom("Space Mono Regular", size: 10))
                                    .lineLimit(1)
                                Spacer()
                                Text(session.startedAt, style: .time)
                                    .font(.system(size: 9))
                                    .opacity(0.5)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .padding()

            Button(action: { currentPage = 0 }) {
                HStack {
                    Image("Back")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 28, maxHeight: 28)
                    Text("Back")
                        .font(.custom("Space Mono Regular", size: 12))
                }
            }
            .buttonStyle(PomoshButtonStyle())
            .offset(x: 12, y: 0)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct StatCard: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.custom("Space Mono Regular", size: 28))
                .foregroundColor(Color("Neon"))
            Text(label)
                .font(.custom("Space Mono Regular", size: 10))
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
