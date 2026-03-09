//
//  ReminderRepository.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import Foundation
import Supabase

@MainActor
class ReminderRepository {
    func fetchAll() async throws -> [Reminder] {
        let response: [Reminder] = try await supabase
            .from("reminders")
            .select()
            .order("remind_at", ascending: true)
            .execute()
            .value
        return response
    }
    
    func fetchById(_ id: UUID) async throws -> Reminder {
        let response: Reminder = try await supabase
            .from("reminders")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return response
    }
    
    func fetchByTaskId(_ taskId: UUID) async throws -> [Reminder] {
        let response: [Reminder] = try await supabase
            .from("reminders")
            .select()
            .eq("task_id", value: taskId)
            .order("remind_at", ascending: true)
            .execute()
            .value
        return response
    }
    
    func insert(_ reminder: ReminderInsert) async throws -> Reminder {
        let response: Reminder = try await supabase
            .from("reminders")
            .insert(reminder)
            .select()
            .single()
            .execute()
            .value
        return response
    }
    
    func update(_ reminder: ReminderUpdate, id: UUID) async throws -> Reminder {
        let response: Reminder = try await supabase
            .from("reminders")
            .update(reminder)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        return response
    }
    
    func delete(id: UUID) async throws {
        try await supabase
            .from("reminders")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
