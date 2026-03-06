//
//  TaskService.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation

@MainActor
class TaskService {

    // MARK: - Dependency
    private let repository: TaskRepository

    init(repository: TaskRepository? = nil) {
        self.repository = repository ?? TaskRepository()
    }

    // MARK: - Fetch & Filter
    func getTasks(
        searchText: String = "",
        showCompleted: Bool = true
    ) async throws -> [TodoTask] {

        var tasks = try await repository.fetchAll()

        // Hide completed tasks if toggled off
        if !showCompleted {
            tasks = tasks.filter { !$0.isCompleted }
        }

        // Filter by search text against title and description
        if !searchText.isEmpty {
            tasks = tasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Sort: incomplete first, then by due date, then by priority
        tasks.sort {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            if let d0 = $0.dueDate, let d1 = $1.dueDate {
                return d0 < d1
            }
            if $0.dueDate != nil { return true }
            if $1.dueDate != nil { return false }
            return priorityRank($0.priority) < priorityRank($1.priority)
        }

        return tasks
    }

    // MARK: - Create
    func createTask(
        title: String,
        description: String? = nil,
        priority: Priority? = nil,
        dueDate: Date? = nil,
        reminderAt: Date? = nil
    ) async throws -> TodoTask {

        // Validation
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw TaskError.emptyTitle
        }

        if let due = dueDate, due < Date() {
            throw TaskError.dueDateInPast
        }

        let insert = TaskInsert(
            title: trimmed,
            description: description,
            priority: priority,
            dueDate: dueDate,
            reminderAt: reminderAt
        )

        return try await repository.insert(insert)
    }

    // MARK: - Update
    func updateTask(
        id: UUID,
        title: String? = nil,
        description: String? = nil,
        priority: Priority? = nil,
        dueDate: Date? = nil,
        reminderAt: Date? = nil
    ) async throws -> TodoTask {

        // Validate title if it's being changed
        if let title = title {
            let trimmed = title.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                throw TaskError.emptyTitle
            }
        }

        let update = TaskUpdate(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            reminderAt: reminderAt
        )

        return try await repository.update(update, id: id)
    }

    // MARK: - Toggle Completion
    func toggleCompletion(task: TodoTask) async throws -> TodoTask {
        let update = TaskUpdate(isCompleted: !task.isCompleted)
        return try await repository.update(update, id: task.id)
    }

    // MARK: - Delete
    func deleteTask(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    // MARK: - Helpers
    private func priorityRank(_ priority: Priority?) -> Int {
        switch priority {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        case .none:   return 3
        }
    }
}

// MARK: - Errors
enum TaskError: LocalizedError {
    case emptyTitle
    case dueDateInPast

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Task title cannot be empty."
        case .dueDateInPast:
            return "Due date cannot be in the past."
        }
    }
}
