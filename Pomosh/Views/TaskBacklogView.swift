//
//  TaskBacklogView.swift
//  Pomosh
//

import SwiftUI
import SwiftData

struct TaskBacklogView: View {
    @Query private var tasks: [PomodoroTask]
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var themeManager = ThemeManager.shared

    let activeTask: PomodoroTask?
    let onStartTask: (PomodoroTask) -> Void
    @Binding var currentPage: Int

    @State private var showAddForm = false
    @State private var newTaskTitle = ""
    @State private var newWorkDuration: Double = 1200
    @State private var newBreakDuration: Double = 600
    @State private var newCycles: Double = 5
    @State private var dropTargetStatus: TaskStatus? = nil
    @State private var editingTaskID: String? = nil
    @State private var editingTitle: String = ""
    @State private var editingWorkDuration: Double = 1200
    @State private var editingBreakDuration: Double = 600
    @State private var editingCycles: Double = 5
    @State private var isListView: Bool = false

    private let statuses: [TaskStatus] = [.backlog, .inProgress, .blocked, .done]

    private func tasksFor(_ status: TaskStatus) -> [PomodoroTask] {
        tasks.filter { $0.status == status }.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────
            HStack(alignment: .center) {
                Text("Tasks")
                    .font(.custom("Space Mono Regular", size: 18))
                Spacer()
                // View toggle
                Button(action: {
                    withAnimation(.spring(response: 0.3)) { isListView.toggle() }
                }) {
                    Image(systemName: isListView ? "square.grid.2x2" : "list.bullet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 6)

                Button(action: {
                    if !showAddForm {
                        newWorkDuration = Double(UserDefaults.standard.optionalInt(forKey: "time") ?? 1200)
                        newBreakDuration = Double(UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600)
                        newCycles = Double(UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5)
                    }
                    withAnimation(.spring(response: 0.3)) { showAddForm.toggle() }
                }) {
                    Image(systemName: showAddForm ? "xmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // ── Add form ─────────────────────────────────────────
            if showAddForm {
                addForm
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // ── Kanban / List ─────────────────────────────────────
            if isListView {
                listView
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                HStack(alignment: .top, spacing: 6) {
                    ForEach(statuses, id: \.self) { status in
                        kanbanColumn(status)
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxHeight: .infinity)
                .transition(.opacity)
            }

            // ── Footer ───────────────────────────────────────────
            HStack {
                Button(action: { currentPage = 0 }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Back")
                            .font(.custom("Space Mono Regular", size: 10))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }

    // MARK: - List View

    private var allTasksSorted: [PomodoroTask] {
        tasks.sorted {
            if $0.status.sortPriority != $1.status.sortPriority {
                return $0.status.sortPriority < $1.status.sortPriority
            }
            return $0.createdAt < $1.createdAt
        }
    }

    @ViewBuilder
    private var listView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(statuses, id: \.self) { status in
                    let group = tasksFor(status)
                    if !group.isEmpty {
                        Section {
                            ForEach(group) { task in
                                listRow(task, status: status)
                                    .padding(.horizontal, 14)
                            }
                        } header: {
                            HStack(spacing: 5) {
                                Image(systemName: status.icon)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(statusColor(status))
                                Text(columnLabel(status))
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("\(group.count)")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(statusColor(status))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(statusColor(status).opacity(0.15))
                                    .clipShape(Capsule())
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                        }
                    }
                }
            }
            .padding(.bottom, 4)
        }
    }

    @ViewBuilder
    private func listRow(_ task: PomodoroTask, status: TaskStatus) -> some View {
        let isActive = task.persistentModelID == activeTask?.persistentModelID
        let isDone = status == .done
        let color = statusColor(status)

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)

                if editingTaskID == task.dragID {
                    TextField("", text: $editingTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11, weight: .medium))
                        .onSubmit { commitEdit(task) }
                        .onExitCommand { editingTaskID = nil }
                } else {
                    Text(task.title)
                        .font(.system(size: 11, weight: .medium))
                        .strikethrough(isDone)
                        .foregroundColor(isDone ? .secondary : .primary)
                        .lineLimit(1)
                        .onTapGesture(count: 2) {
                            editingTaskID = task.dragID
                            editingTitle = task.title
                            editingWorkDuration = Double(task.workDuration)
                            editingBreakDuration = Double(task.breakDuration)
                            editingCycles = Double(task.cycles)
                        }
                }

                Spacer()

                if editingTaskID != task.dragID {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(task.workDuration / 60)m · \(task.cycles)c")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.secondary)
                        if !task.timeSpentDisplay.isEmpty {
                            Text(task.timeSpentDisplay)
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundColor(color.opacity(0.8))
                        }
                    }

                    if status == .backlog || status == .inProgress {
                        Button(action: { onStartTask(task) }) {
                            Image(systemName: isActive ? "play.fill" : "play")
                                .font(.system(size: 10))
                                .foregroundColor(isActive ? color : .secondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if editingTaskID == task.dragID {
                HStack(spacing: 10) {
                    sliderField(label: "Work", value: $editingWorkDuration,
                                display: "\(Int(editingWorkDuration)/60)m",
                                range: 300...3600, step: 300)
                    sliderField(label: "Break", value: $editingBreakDuration,
                                display: "\(Int(editingBreakDuration)/60)m",
                                range: 300...1200, step: 60)
                    sliderField(label: "Cycles", value: $editingCycles,
                                display: "\(Int(editingCycles))",
                                range: 1...8, step: 1)
                }
                HStack(spacing: 10) {
                    Button(action: { commitEdit(task) }) {
                        Text("Save")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(color)
                    }
                    .buttonStyle(.plain)
                    Button(action: { editingTaskID = nil }) {
                        Text("Cancel")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive ? color.opacity(0.1) : Color.white.opacity(0.03))
        )
        .opacity(isDone ? 0.55 : 1)
        .padding(.vertical, 2)
        .contextMenu {
            ForEach(TaskStatus.allCases, id: \.self) { s in
                Button(action: {
                    task.status = s
                    if s == .done { task.completedAt = Date() }
                    try? modelContext.save()
                }) {
                    Label(s.rawValue, systemImage: s.icon)
                }
            }
            Divider()
            Button(role: .destructive, action: { modelContext.delete(task) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Kanban Column

    @ViewBuilder
    private func kanbanColumn(_ status: TaskStatus) -> some View {
        let columnTasks = tasksFor(status)
        let isTarget = dropTargetStatus == status
        let color = statusColor(status)

        VStack(spacing: 0) {
            // Column header
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: status.icon)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(color)
                    Spacer()
                    if columnTasks.count > 0 {
                        Text("\(columnTasks.count)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(color)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(columnLabel(status))
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 5)
            .background(color.opacity(0.1))
            .overlay(alignment: .top) {
                color
                    .frame(height: 2)
                    .cornerRadius(1)
            }

            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 4) {
                    ForEach(columnTasks) { task in
                        taskCard(task, status: status, color: color)
                    }

                    if columnTasks.isEmpty {
                        Text("Drop here")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary.opacity(isTarget ? 0.6 : 0.0))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                }
                .padding(4)
            }
            .background(Color.white.opacity(isTarget ? 0.06 : 0.02))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isTarget ? color.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isTarget ? 1.5 : 1)
        )
        .dropDestination(for: String.self) { items, _ in
            guard let dragID = items.first,
                  let task = tasks.first(where: { $0.dragID == dragID }) else { return false }
            withAnimation {
                task.status = status
                if status == .done { task.completedAt = Date() }
                try? modelContext.save()
            }
            return true
        } isTargeted: { isTargeted in
            withAnimation(.easeInOut(duration: 0.15)) {
                dropTargetStatus = isTargeted ? status : nil
            }
        }
    }

    // MARK: - Task Card

    @ViewBuilder
    private func taskCard(_ task: PomodoroTask, status: TaskStatus, color: Color) -> some View {
        let isActive = task.persistentModelID == activeTask?.persistentModelID
        let isDone = status == .done

        VStack(alignment: .leading, spacing: 4) {
            if editingTaskID == task.dragID {
                // ── Edit mode ──────────────────────────────────
                TextField("", text: $editingTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 9, weight: .medium))
                    .onSubmit { commitEdit(task) }
                    .onExitCommand { editingTaskID = nil }

                sliderField(label: "Work", value: $editingWorkDuration,
                            display: "\(Int(editingWorkDuration)/60)m",
                            range: 300...3600, step: 300)
                sliderField(label: "Break", value: $editingBreakDuration,
                            display: "\(Int(editingBreakDuration)/60)m",
                            range: 300...1200, step: 60)
                sliderField(label: "Cycles", value: $editingCycles,
                            display: "\(Int(editingCycles))",
                            range: 1...8, step: 1)

                HStack(spacing: 6) {
                    Button(action: { commitEdit(task) }) {
                        Text("Save")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(color)
                    }
                    .buttonStyle(.plain)
                    Button(action: { editingTaskID = nil }) {
                        Text("Cancel")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // ── Display mode ────────────────────────────────
                Text(task.title)
                    .font(.system(size: 9, weight: .medium))
                    .lineLimit(3)
                    .strikethrough(isDone)
                    .foregroundColor(isDone ? .secondary : .primary)
                    .onTapGesture(count: 2) {
                        editingTaskID = task.dragID
                        editingTitle = task.title
                        editingWorkDuration = Double(task.workDuration)
                        editingBreakDuration = Double(task.breakDuration)
                        editingCycles = Double(task.cycles)
                    }

                HStack(spacing: 0) {
                    Text("\(task.workDuration / 60)m")
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.secondary)
                    if !task.timeSpentDisplay.isEmpty {
                        Text(" · \(task.timeSpentDisplay)")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(color.opacity(0.8))
                    }
                    Spacer(minLength: 0)
                    if status == .backlog || status == .inProgress {
                        Button(action: { onStartTask(task) }) {
                            Image(systemName: isActive ? "play.fill" : "play")
                                .font(.system(size: 8))
                                .foregroundColor(isActive ? color : .secondary.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isActive ? color.opacity(0.14) : Color.white.opacity(0.05))
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 2)
        }
        .opacity(isDone ? 0.55 : 1)
        .draggable(task.dragID)
        .contextMenu {
            ForEach(TaskStatus.allCases, id: \.self) { s in
                Button(action: {
                    task.status = s
                    if s == .done { task.completedAt = Date() }
                    try? modelContext.save()
                }) {
                    Label(s.rawValue, systemImage: s.icon)
                }
            }
            Divider()
            Button(role: .destructive, action: { modelContext.delete(task) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Add Form

    @ViewBuilder
    private var addForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("Task name...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .onSubmit { saveNewTask() }

                Button(action: saveNewTask) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(
                            newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty
                                ? .secondary.opacity(0.3)
                                : themeManager.currentTheme.accentColor
                        )
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.07))
            .cornerRadius(8)

            HStack(spacing: 10) {
                sliderField(label: "Work", value: $newWorkDuration,
                            display: "\(Int(newWorkDuration)/60)m",
                            range: 300...3600, step: 300)
                sliderField(label: "Break", value: $newBreakDuration,
                            display: "\(Int(newBreakDuration)/60)m",
                            range: 300...1200, step: 60)
                sliderField(label: "Cycles", value: $newCycles,
                            display: "\(Int(newCycles))",
                            range: 1...8, step: 1)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func sliderField(label: String, value: Binding<Double>, display: String, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Spacer()
                Text(display)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
            Slider(value: value, in: range, step: step)
                .tint(themeManager.currentTheme.accentColor)
        }
    }

    // MARK: - Helpers

    private func columnLabel(_ status: TaskStatus) -> String {
        switch status {
        case .backlog:    return "BACKLOG"
        case .inProgress: return "IN PROG"
        case .blocked:    return "BLOCKED"
        case .done:       return "DONE"
        }
    }

    private func statusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .backlog:    return .secondary
        case .inProgress: return themeManager.currentTheme.accentColor
        case .blocked:    return .red
        case .done:       return .green
        }
    }

    private func commitEdit(_ task: PomodoroTask) {
        let trimmed = editingTitle.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            task.title = trimmed
            task.workDuration = Int(editingWorkDuration)
            task.breakDuration = Int(editingBreakDuration)
            task.cycles = Int(editingCycles)
            try? modelContext.save()
        }
        editingTaskID = nil
    }

    private func saveNewTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let task = PomodoroTask(title: trimmed)
        task.workDuration = Int(newWorkDuration)
        task.breakDuration = Int(newBreakDuration)
        task.cycles = Int(newCycles)
        modelContext.insert(task)
        try? modelContext.save()

        newTaskTitle = ""
        withAnimation { showAddForm = false }
    }
}
