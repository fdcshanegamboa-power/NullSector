//
//  ReminderDetailViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation

@MainActor
@Observable
class ReminderDetailViewModel {
    
    // MARK: - State
    var reminder: Reminder?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showDeleteConfirmation: Bool = false
    var isDeleted: Bool = false
    
    private let reminderService: ReminderService
    private let notificationService: NotificationService
    private let reminderId: UUID
    
    init(
        reminderId: UUID,
        reminderService: ReminderService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.reminderId = reminderId
        self.reminderService = reminderService ?? ReminderService()
        self.notificationService = notificationService ?? NotificationService.shared
    }
    
    func fetchReminder() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            reminder = try await reminderService.getReminderById(reminderId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func dismissReminder() async {
        guard let reminder = reminder else { return }
        
        do {
            let updated = try await reminderService.dismissReminder(id: reminder.id)
            notificationService.cancelReminder(for: updated.id)
            self.reminder = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func restoreReminder() async {
        guard let reminder = reminder else { return }
        
        do {
            let updated = try await reminderService.restoreReminder(id: reminder.id)
            
            if updated.remindAt > Date() {
                notificationService.scheduleReminderNotification(for: updated)
            }
            
            self.reminder = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteReminder() async {
        guard let reminder = reminder else { return }
        
        do {
            try await reminderService.deleteReminder(id: reminder.id)
            notificationService.cancelReminder(for: reminder.id)
            isDeleted = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func requestDelete() {
        showDeleteConfirmation = true
    }
    
    func confirmDelete() async {
        await deleteReminder()
    }
    
    func cancelDelete() {
        showDeleteConfirmation = false
    }
}
