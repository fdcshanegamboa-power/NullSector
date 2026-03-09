//
//  ReminderService.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation

@MainActor
class ReminderService {

    // MARK: - Dependency
    private let repository: ReminderRepository

    init(repository: ReminderRepository? = nil) {
        self.repository = repository ?? ReminderRepository()
    }

    // MARK: - Fetch & Filter
    func getReminders(
        searchText: String = "",
        showDismissed: Bool = false,
        sortOption: ReminderListViewModel.SortOption = .remindAtAsc
    ) async throws -> [Reminder] {

        var reminders = try await repository.fetchAll()

        // Hide dismissed reminders if toggled off
        if !showDismissed {
            reminders = reminders.filter { !$0.isDismissed }
        }

        // Filter by search text
        if !searchText.isEmpty {
            reminders = reminders.filter {
                $0.message.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sort
        reminders.sort { a, b in
            // Always keep undismissed reminders above dismissed ones
            if a.isDismissed != b.isDismissed {
                return !a.isDismissed
            }

            switch sortOption {
            case .remindAtAsc:
                return a.remindAt < b.remindAt
            case .remindAtDesc:
                return a.remindAt > b.remindAt
            case .createdNewest:
                return a.createdAt > b.createdAt
            case .createdOldest:
                return a.createdAt < b.createdAt
            case .titleAZ:
                return a.message.localizedCompare(b.message) == .orderedAscending
            case .titleZA:
                return a.message.localizedCompare(b.message) == .orderedDescending
            }
        }

        return reminders
    }

    func getReminderById(_ id: UUID) async throws -> Reminder {
        return try await repository.fetchById(id)
    }

    func getRemindersByTaskId(_ taskId: UUID) async throws -> [Reminder] {
        return try await repository.fetchByTaskId(taskId)
    }

    // MARK: - Create
    func createReminder(
        message: String,
        remindAt: Date,
        taskId: UUID? = nil,
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        recurrenceEndsAt: Date? = nil
    ) async throws -> Reminder {

        let trimmed = message.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw ReminderError.emptyMessage
        }

        if remindAt < Date() {
            throw ReminderError.remindAtInPast
        }

        if isRecurring && recurrenceRule == nil {
            throw ReminderError.missingRecurrenceRule
        }

        if let endsAt = recurrenceEndsAt, endsAt <= remindAt {
            throw ReminderError.invalidRecurrenceEndDate
        }

        let insert = ReminderInsert(
            taskId: taskId,
            message: trimmed,
            remindAt: remindAt,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            recurrenceEndsAt: recurrenceEndsAt
        )

        return try await repository.insert(insert)
    }

    // MARK: - Update
    func updateReminder(
        id: UUID,
        message: String? = nil,
        remindAt: Date? = nil,
        taskId: UUID? = nil,
        isRecurring: Bool? = nil,
        recurrenceRule: RecurrenceRule? = nil,
        recurrenceEndsAt: Date? = nil
    ) async throws -> Reminder {

        if let message = message {
            let trimmed = message.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                throw ReminderError.emptyMessage
            }
        }

        if let remindAt = remindAt, remindAt < Date() {
            throw ReminderError.remindAtInPast
        }

        let update = ReminderUpdate(
            taskId: taskId,
            message: message,
            remindAt: remindAt,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            recurrenceEndsAt: recurrenceEndsAt
        )

        return try await repository.update(update, id: id)
    }

    // MARK: - Dismiss / Restore
    func dismissReminder(id: UUID) async throws -> Reminder {
        let update = ReminderUpdate(isDismissed: true)
        let dismissed = try await repository.update(update, id: id)

        if dismissed.isRecurring, let rule = dismissed.recurrenceRule {
            try await createNextRecurrence(from: dismissed, rule: rule)
        }

        return dismissed
    }

    func restoreReminder(id: UUID) async throws -> Reminder {
        let update = ReminderUpdate(isDismissed: false)
        return try await repository.update(update, id: id)
    }

    // MARK: - Delete
    func deleteReminder(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    // MARK: - Recurrence Logic
    private func createNextRecurrence(from reminder: Reminder, rule: RecurrenceRule) async throws {
        let nextRemindAt = calculateNextOccurrence(from: reminder.remindAt, rule: rule)

        if let endsAt = reminder.recurrenceEndsAt, nextRemindAt > endsAt {
            return
        }

        let insert = ReminderInsert(
            taskId: reminder.taskId,
            message: reminder.message,
            remindAt: nextRemindAt,
            isRecurring: true,
            recurrenceRule: rule,
            recurrenceEndsAt: reminder.recurrenceEndsAt
        )

        _ = try await repository.insert(insert)
    }

    private func calculateNextOccurrence(from date: Date, rule: RecurrenceRule) -> Date {
        let calendar = Calendar.current

        switch rule {
        case .daily:   return calendar.date(byAdding: .day,        value: 1, to: date) ?? date
        case .weekly:  return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly: return calendar.date(byAdding: .month,      value: 1, to: date) ?? date
        case .yearly:  return calendar.date(byAdding: .year,       value: 1, to: date) ?? date
        }
    }
}

// MARK: - Errors
enum ReminderError: LocalizedError {
    case emptyMessage
    case remindAtInPast
    case missingRecurrenceRule
    case invalidRecurrenceEndDate

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Reminder message cannot be empty."
        case .remindAtInPast:
            return "Reminder time cannot be in the past."
        case .missingRecurrenceRule:
            return "Recurring reminders must have a recurrence rule."
        case .invalidRecurrenceEndDate:
            return "Recurrence end date must be after the reminder time."
        }
    }
}