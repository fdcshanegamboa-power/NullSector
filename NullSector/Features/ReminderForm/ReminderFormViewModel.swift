//
//  ReminderFormViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation

@MainActor
@Observable
class ReminderFormViewModel {
    
    // MARK: - Form State
    var message: String = ""
    var remindAt: Date = Date().addingTimeInterval(3600) // Default to 1 hour from now
    var isRecurring: Bool = false
    var recurrenceRule: RecurrenceRule? = nil
    var hasRecurrenceEnd: Bool = false
    var recurrenceEndsAt: Date = Date().addingTimeInterval(86400 * 30) // Default to 30 days
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isSaved: Bool = false
    
    private let reminderService: ReminderService
    private let notificationService: NotificationService
    private let reminderToEdit: Reminder?
    
    var isEditing: Bool {
        reminderToEdit != nil
    }
    
    init(
        reminder: Reminder? = nil,
        reminderService: ReminderService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.reminderToEdit = reminder
        self.reminderService = reminderService ?? ReminderService()
        self.notificationService = notificationService ?? NotificationService.shared
        
        // Populate form if editing
        if let reminder = reminder {
            self.message = reminder.message
            self.remindAt = reminder.remindAt
            self.isRecurring = reminder.isRecurring
            self.recurrenceRule = reminder.recurrenceRule
            self.hasRecurrenceEnd = reminder.recurrenceEndsAt != nil
            self.recurrenceEndsAt = reminder.recurrenceEndsAt ?? Date().addingTimeInterval(86400 * 30)
        }
    }
    
    func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let finalRecurrenceEndsAt = hasRecurrenceEnd ? recurrenceEndsAt : nil
            
            if let existing = reminderToEdit {
                // Update existing reminder
                let updated = try await reminderService.updateReminder(
                    id: existing.id,
                    message: message,
                    remindAt: remindAt,
                    isRecurring: isRecurring,
                    recurrenceRule: isRecurring ? recurrenceRule : nil,
                    recurrenceEndsAt: isRecurring ? finalRecurrenceEndsAt : nil
                )
                
                // Reschedule notification
                notificationService.cancelReminder(for: updated.id)
                if !updated.isDismissed && updated.remindAt > Date() {
                    notificationService.scheduleReminderNotification(for: updated)
                }
            } else {
                // Create new reminder
                let created = try await reminderService.createReminder(
                    message: message,
                    remindAt: remindAt,
                    isRecurring: isRecurring,
                    recurrenceRule: isRecurring ? recurrenceRule : nil,
                    recurrenceEndsAt: isRecurring ? finalRecurrenceEndsAt : nil
                )
                
                // Schedule notification
                if created.remindAt > Date() {
                    notificationService.scheduleReminderNotification(for: created)
                }
            }
            
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func reset() {
        message = ""
        remindAt = Date().addingTimeInterval(3600)
        isRecurring = false
        recurrenceRule = nil
        hasRecurrenceEnd = false
        recurrenceEndsAt = Date().addingTimeInterval(86400 * 30)
        errorMessage = nil
        isSaved = false
    }
}
