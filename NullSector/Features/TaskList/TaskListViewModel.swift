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

    // MARK: - State
    var tasks: [TodoTask] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var searchText: String = ""
    var showCompleted: Bool = true

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
                showCompleted: showCompleted
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
}
