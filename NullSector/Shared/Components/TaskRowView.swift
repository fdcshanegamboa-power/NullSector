//
//  TaskRowView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct TaskRowView: View {

    let task: TodoTask
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // MARK: - Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // MARK: - Content
            VStack(alignment: .leading, spacing: 6) {

                // Title
                Text(task.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                // Description
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // MARK: - Badges Row
                HStack(spacing: 8) {

                    // Priority Badge
                    if let priority = task.priority {
                        PriorityBadgeView(priority: priority)
                    }

                    // Due Date
                    if let dueDate = task.dueDate {
                        DueDateLabelView(date: dueDate)
                    }
                    
                    // Reminder indicator
                    if task.reminderAt != nil {
                        HStack(spacing: 2) {
                            Image(systemName: "bell.fill")
                            Text("Reminder")
                        }
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.purple)
                    }
                }
                .padding(.top, 2)
                
                // MARK: - Metadata Row
                HStack(spacing: 12) {
                    // Created date
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("Created \(formatRelativeDate(task.createdAt))")
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    
                    // Updated indicator
                    if let updatedAt = task.updatedAt, updatedAt > task.createdAt {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Updated")
                        }
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    }
                }
                .padding(.top, 2)
            }

            Spacer()
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
    
    // MARK: - Helper Functions
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
