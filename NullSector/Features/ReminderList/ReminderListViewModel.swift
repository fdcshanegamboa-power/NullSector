//
//  ReminderListViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation

@MainActor
@Observable
class ReminderListViewModel {

    // MARK: - Sort Options
    enum SortOption: String, CaseIterable, Identifiable {
        case remindAtAsc    = "Remind At (Earliest)"
        case remindAtDesc   = "Remind At (Latest)"
        case createdNewest  = "Date Created (Newest)"
        case createdOldest  = "Date Created (Oldest)"
        case titleAZ        = "Title (A–Z)"
        case titleZA        = "Title (Z–A)"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .remindAtAsc, .remindAtDesc:    return "bell.circle"
            case .createdNewest, .createdOldest: return "calendar"
            case .titleAZ, .titleZA:             return "textformat.abc"
            }
        }
    }

    // MARK: - State
    var reminders: [Reminder] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var searchText: String = ""
    var showDismissed: Bool = false
    var sortOption: SortOption = .remindAtAsc
    var reminderPendingDelete: Reminder? = nil
    var showDeleteConfirmation: Bool = false

    private let reminderService: ReminderService
    private let notificationService: NotificationService

    init(
        reminderService: ReminderService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.reminderService = reminderService ?? ReminderService()
        self.notificationService = notificationService ?? NotificationService.shared
    }

    func fetchReminders() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            reminders = try await reminderService.getReminders(
                searchText: searchText,
                showDismissed: showDismissed,
                sortOption: sortOption
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissReminder(_ reminder: Reminder) async {
        do {
            let updated = try await reminderService.dismissReminder(id: reminder.id)
            notificationService.cancelReminder(for: updated.id)

            if let index = reminders.firstIndex(where: { $0.id == updated.id }) {
                reminders[index] = updated
            }

            if reminder.isRecurring {
                await fetchReminders()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restoreReminder(_ reminder: Reminder) async {
        do {
            let updated = try await reminderService.restoreReminder(id: reminder.id)

            if updated.remindAt > Date() {
                scheduleNotification(for: updated)
            }

            if let index = reminders.firstIndex(where: { $0.id == updated.id }) {
                reminders[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteReminder(_ reminder: Reminder) async {
        do {
            try await reminderService.deleteReminder(id: reminder.id)
            notificationService.cancelReminder(for: reminder.id)
            reminders.removeAll { $0.id == reminder.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Request Delete
    func requestDelete(_ reminder: Reminder) {
        reminderPendingDelete = reminder
        showDeleteConfirmation = true
    }

    // MARK: - Confirm Delete
    func confirmDelete() async {
        guard let reminder = reminderPendingDelete else { return }
        await deleteReminder(reminder)
        reminderPendingDelete = nil
    }

    // MARK: - Cancel Delete
    func cancelDelete() {
        reminderPendingDelete = nil
        showDeleteConfirmation = false
    }

    // MARK: - Notification Scheduling
    private func scheduleNotification(for reminder: Reminder) {
        notificationService.scheduleReminderNotification(for: reminder)
    }
}