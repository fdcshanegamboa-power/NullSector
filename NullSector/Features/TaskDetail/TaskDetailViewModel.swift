//
//  TaskDetailViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation

@MainActor
@Observable
class TaskDetailViewModel {

    var task: TodoTask
    var errorMessage: String?
    var isLoading: Bool = false
    var isTogglingCompletion: Bool = false

    private let taskService: TaskService

    init(task: TodoTask, taskService: TaskService? = nil) {
        self.task = task
        self.taskService = taskService ?? TaskService()
    }

    // MARK: - Toggle Completion
    func toggleCompletion() async {
        isTogglingCompletion = true
        defer { isTogglingCompletion = false }
        
        do {
            let updated = try await taskService.toggleCompletion(task: task)
            task = updated
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Task
    func fetchTask() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let tasks = try await taskService.getTasks()
            if let updatedTask = tasks.first(where: { $0.id == task.id }) {
                task = updatedTask
            }
        } catch {
            errorMessage = "Failed to refresh task: \(error.localizedDescription)"
        }
    }
}
