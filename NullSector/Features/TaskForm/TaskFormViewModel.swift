//
//  TaskFormViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation

@MainActor
@Observable
class TaskFormViewModel {

    // MARK: - Form Fields
    var title: String = ""
    var description: String = ""
    var priority: Priority? = nil
    var dueDate: Date? = nil
    var reminderAt: Date? = nil
    var hasDueDate: Bool = false
    var hasReminder: Bool = false

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var didSave: Bool = false

    // MARK: - Mode
    private var existingTask: TodoTask? = nil
    var isEditMode: Bool { existingTask != nil }

    // MARK: - Dependencies
    private let taskService: TaskService
    private let notificationService: NotificationService

    init(
        task: TodoTask? = nil,
        taskService: TaskService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.existingTask = task
        self.taskService = taskService ?? TaskService()
        self.notificationService = notificationService ?? NotificationService.shared

        // Pre-populate fields if editing
        if let task = task {
            self.title        = task.title
            self.description  = task.description ?? ""
            self.priority     = task.priority
            self.hasDueDate   = task.dueDate != nil
            self.dueDate      = task.dueDate ?? Date()
            self.hasReminder  = task.reminderAt != nil
            self.reminderAt   = task.reminderAt ?? Date()
        }
    }

    // MARK: - Save
    func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let finalDueDate    = hasDueDate ? dueDate : nil
            let finalReminderAt = hasReminder ? reminderAt : nil

            if isEditMode {
                guard let id = existingTask?.id else { return }

                let updated = try await taskService.updateTask(
                    id: id,
                    title: title,
                    description: description.isEmpty ? nil : description,
                    priority: priority,
                    dueDate: finalDueDate,
                    reminderAt: finalReminderAt
                )

                // Handle notification — cancel old, schedule new if needed
                notificationService.cancelReminder(for: id)
                if !updated.isCompleted, let _ = updated.reminderAt {
                    notificationService.scheduleReminder(for: updated)
                }

            } else {
                let created = try await taskService.createTask(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    priority: priority,
                    dueDate: finalDueDate,
                    reminderAt: finalReminderAt
                )

                // Schedule notification for new task if reminder was set
                if let _ = created.reminderAt {
                    notificationService.scheduleReminder(for: created)
                }
            }

            didSave = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
