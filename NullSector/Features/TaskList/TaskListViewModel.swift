//
//  TaskListViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation

@MainActor
@Observable
class TaskListViewModel {

    // MARK: - Sort Options
    enum SortOption: String, CaseIterable, Identifiable {
        case createdNewest  = "Date Created (Newest)"
        case createdOldest  = "Date Created (Oldest)"
        case dueDateAsc     = "Due Date (Earliest)"
        case dueDateDesc    = "Due Date (Latest)"
        case titleAZ        = "Title (A–Z)"
        case titleZA        = "Title (Z–A)"
        case priority       = "Priority"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .createdNewest, .createdOldest: return "calendar"
            case .dueDateAsc, .dueDateDesc:      return "clock"
            case .titleAZ, .titleZA:             return "textformat.abc"
            case .priority:                      return "exclamationmark.circle"
            }
        }
    }

    // MARK: - State
    var tasks: [TodoTask] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var searchText: String = ""
    var showCompleted: Bool = false
    var sortOption: SortOption = .createdNewest
    var taskPendingDelete: TodoTask? = nil
    var showDeleteConfirmation: Bool = false

    private let taskService: TaskService
    private let notificationService: NotificationService

    init(
        taskService: TaskService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.taskService = taskService ?? TaskService()
        self.notificationService = notificationService ?? NotificationService.shared
    }

    func fetchTasks() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tasks = try await taskService.getTasks(
                searchText: searchText,
                showCompleted: showCompleted,
                sortOption: sortOption
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(task: TodoTask) async {
        do {
            let updated = try await taskService.toggleCompletion(task: task)

            if updated.isCompleted {
                notificationService.cancelReminder(for: updated.id)
            } else if updated.reminderAt != nil {
                notificationService.scheduleReminder(for: updated)
            }

            if let index = tasks.firstIndex(where: { $0.id == updated.id }) {
                tasks[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TodoTask) async {
        do {
            try await taskService.deleteTask(id: task.id)
            notificationService.cancelReminder(for: task.id)
            tasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Request Delete
    func requestDelete(_ task: TodoTask) {
        taskPendingDelete = task
        showDeleteConfirmation = true
    }

    // MARK: - Confirm Delete
    func confirmDelete() async {
        guard let task = taskPendingDelete else { return }
        await deleteTask(task)
        taskPendingDelete = nil
    }

    // MARK: - Cancel Delete
    func cancelDelete() {
        taskPendingDelete = nil
        showDeleteConfirmation = false
    }
}