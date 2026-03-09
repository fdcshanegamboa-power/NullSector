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
        showCompleted: Bool = true,
        sortOption: TaskListViewModel.SortOption = .createdNewest
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

        // Apply sort
        tasks.sort { a, b in
            // Always keep incomplete tasks above completed ones
            if a.isCompleted != b.isCompleted {
                return !a.isCompleted
            }

            switch sortOption {
            case .createdNewest:
                return a.createdAt > b.createdAt
            case .createdOldest:
                return a.createdAt < b.createdAt
            case .dueDateAsc:
                return compareDates(a.dueDate, b.dueDate, ascending: true)
            case .dueDateDesc:
                return compareDates(a.dueDate, b.dueDate, ascending: false)
            case .titleAZ:
                return a.title.localizedCompare(b.title) == .orderedAscending
            case .titleZA:
                return a.title.localizedCompare(b.title) == .orderedDescending
            case .priority:
                return priorityRank(a.priority) < priorityRank(b.priority)
            }
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

    /// Sorts by due date, pushing nil dates to the bottom regardless of direction.
    private func compareDates(_ a: Date?, _ b: Date?, ascending: Bool) -> Bool {
        switch (a, b) {
        case let (a?, b?): return ascending ? a < b : a > b
        case (_?, nil):    return true   // a has date, b doesn't → a wins
        case (nil, _?):    return false  // b has date, a doesn't → b wins
        case (nil, nil):   return false
        }
    }

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