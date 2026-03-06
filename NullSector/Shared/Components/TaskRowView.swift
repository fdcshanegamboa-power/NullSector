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
        HStack(alignment: .top, spacing: 16) {

            // MARK: - Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? Color.successGreen.opacity(0.1) : Color.gray.opacity(0.05))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.isCompleted ? Color.successGreen : Color.textSecondary)
                }
            }
            .buttonStyle(.plain)

            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {

                // Title
                Text(task.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .strikethrough(task.isCompleted, color: Color.textSecondary)
                    .foregroundStyle(task.isCompleted ? Color.textSecondary : Color.textPrimary)

                // Description
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
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
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text("Reminder")
                                .font(.caption2)
                        }
                        .fontWeight(.medium)
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                
                // MARK: - Metadata Row
                HStack(spacing: 12) {
                    // Created date
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatRelativeDate(task.createdAt))
                            .font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary.opacity(0.8))
                    
                    // Updated indicator
                    if let updatedAt = task.updatedAt, updatedAt > task.createdAt {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                            Text("Updated")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.textSecondary.opacity(0.8))
                    }
                }
            }

            Spacer()
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.brandPrimaryEnd.opacity(0.5))
                .padding(.top, 6)
        }
        .padding(16)
        .opacity(task.isCompleted ? 0.7 : 1.0)
    }
    
    // MARK: - Helper Functions
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
