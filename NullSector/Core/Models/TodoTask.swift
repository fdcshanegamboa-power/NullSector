//
//  Task.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation


struct TodoTask: Codable, Identifiable, Hashable{
    let id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var priority: Priority?
    var dueDate: Date?
    var reminderAt: Date?
    let createdAt: Date
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted  = "is_completed"
        case priority
        case dueDate      = "due_date"
        case reminderAt   = "reminder_at"
        case createdAt    = "created_at"
        case updatedAt    = "updated_at"
    }
}

struct TaskInsert: Encodable {
    var title: String
    var description: String?
    var isCompleted: Bool = false
    var priority: Priority?
    var dueDate: Date?
    var reminderAt: Date?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case isCompleted  = "is_completed"
        case priority
        case dueDate      = "due_date"
        case reminderAt   = "reminder_at"
    }
}

struct TaskUpdate: Encodable {
    var title: String?
    var description: String?
    var isCompleted: Bool?
    var priority: Priority?
    var dueDate: Date?
    var reminderAt: Date?
    var updatedAt: Date? = Date()

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case isCompleted  = "is_completed"
        case priority
        case dueDate      = "due_date"
        case reminderAt   = "reminder_at"
        case updatedAt    = "updated_at"
    }
}
