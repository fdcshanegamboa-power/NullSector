//
//  TaskRepository.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation
import Supabase

@MainActor
class TaskRepository {
    func fetchAll() async throws -> [TodoTask] {
        let response: [TodoTask] = try await supabase
            .from("tasks")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    func insert(_ task: TaskInsert) async throws -> TodoTask {
        let response: TodoTask = try await supabase
            .from("tasks")
            .insert(task)
            .select()
            .single()
            .execute()
            .value
        return response
    }
    
    func update(_ task: TaskUpdate, id: UUID) async throws -> TodoTask {
        let response: TodoTask = try await supabase
            .from("tasks")
            .update(task)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value

        return response
    }

    func delete(id: UUID) async throws {
        try await supabase
            .from("tasks")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
