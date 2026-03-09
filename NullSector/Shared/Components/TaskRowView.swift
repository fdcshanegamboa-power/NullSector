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
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {

            // MARK: - Priority Color Bar
            RoundedRectangle(cornerRadius: 3)
                .fill(task.priority?.color ?? Color.textSecondary.opacity(0.15))
                .frame(width: 4)
                .padding(.vertical, 4)
                .padding(.trailing, 12)

            // MARK: - Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? Color.successGreen.opacity(0.1) : Color.gray.opacity(0.05))
                        .frame(width: 36, height: 36)

                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.isCompleted ? Color.successGreen : Color.textSecondary)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)

            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {

                // Title
                Text(task.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .strikethrough(task.isCompleted, color: Color.textSecondary)
                    .foregroundStyle(task.isCompleted ? Color.textSecondary : Color.textPrimary)
                    .lineLimit(2)

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
                        DueDateLabelView(date: dueDate, isCompleted: task.isCompleted)
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
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(formatRelativeDate(task.createdAt))
                            .font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary.opacity(0.7))

                    if let updatedAt = task.updatedAt, updatedAt > task.createdAt {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                            Text("Updated")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.textSecondary.opacity(0.7))
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.brandPrimaryEnd.opacity(0.5))
                .padding(.top, 6)
        }
        .padding(16)
        .opacity(task.isCompleted ? 0.7 : 1.0)
        // MARK: - Swipe Left: Delete + Edit
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        // MARK: - Swipe Right: Toggle Complete
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onToggle()
            } label: {
                Label(
                    task.isCompleted ? "Undo" : "Done",
                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(task.isCompleted ? .orange : Color.successGreen)
        }
    }

    // MARK: - Helpers
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
