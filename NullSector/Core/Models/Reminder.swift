//
//  Reminder.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation

enum RecurrenceRule: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

struct Reminder: Codable, Identifiable, Hashable {
    let id: UUID
    var taskId: UUID?
    var message: String
    var remindAt: Date
    var isDismissed: Bool
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var recurrenceEndsAt: Date?
    let createdAt: Date
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case message
        case remindAt = "remind_at"
        case isDismissed = "is_dismissed"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case recurrenceEndsAt = "recurrence_ends_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ReminderInsert: Encodable {
    var taskId: UUID?
    var message: String
    var remindAt: Date
    var isDismissed: Bool = false
    var isRecurring: Bool = false
    var recurrenceRule: RecurrenceRule?
    var recurrenceEndsAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case message
        case remindAt = "remind_at"
        case isDismissed = "is_dismissed"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case recurrenceEndsAt = "recurrence_ends_at"
    }
}

struct ReminderUpdate: Encodable {
    var taskId: UUID?
    var message: String?
    var remindAt: Date?
    var isDismissed: Bool?
    var isRecurring: Bool?
    var recurrenceRule: RecurrenceRule?
    var recurrenceEndsAt: Date?
    var updatedAt: Date? = Date()
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case message
        case remindAt = "remind_at"
        case isDismissed = "is_dismissed"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case recurrenceEndsAt = "recurrence_ends_at"
        case updatedAt = "updated_at"
    }
}
