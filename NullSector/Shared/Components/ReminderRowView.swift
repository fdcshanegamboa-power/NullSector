//
//  ReminderRowView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import SwiftUI

struct ReminderRowView: View {
    
    let reminder: Reminder
    let onDismiss: () -> Void
    let onRestore: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            // MARK: - Status Indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(reminder.isDismissed ? Color.textSecondary.opacity(0.15) : Color.brandPrimaryEnd)
                .frame(width: 4)
                .padding(.vertical, 4)
                .padding(.trailing, 12)
            
            // MARK: - Icon
            ZStack {
                Circle()
                    .fill(reminder.isDismissed ? Color.gray.opacity(0.05) : Color.brandPrimaryEnd.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: reminder.isDismissed ? "checkmark.circle.fill" : "bell.fill")
                    .font(.title3)
                    .foregroundStyle(reminder.isDismissed ? Color.textSecondary : Color.brandPrimaryEnd)
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(.trailing, 12)
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {
                
                // Message
                Text(reminder.message)
                    .font(.body)
                    .fontWeight(.semibold)
                    .strikethrough(reminder.isDismissed, color: Color.textSecondary)
                    .foregroundStyle(reminder.isDismissed ? Color.textSecondary : Color.textPrimary)
                    .lineLimit(2)
                
                // MARK: - Badges Row
                HStack(spacing: 8) {
                    
                    // Remind At Label
                    RemindAtLabelView(date: reminder.remindAt, isDismissed: reminder.isDismissed)
                    
                    // Recurring indicator
                    if reminder.isRecurring, let rule = reminder.recurrenceRule {
                        HStack(spacing: 3) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text(rule.rawValue.capitalized)
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
                        Text(formatRelativeDate(reminder.createdAt))
                            .font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary.opacity(0.7))
                    
                    if let updatedAt = reminder.updatedAt, updatedAt > reminder.createdAt {
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
        .opacity(reminder.isDismissed ? 0.7 : 1.0)
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
        // MARK: - Swipe Right: Dismiss / Restore
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                if reminder.isDismissed {
                    onRestore()
                } else {
                    onDismiss()
                }
            } label: {
                Label(
                    reminder.isDismissed ? "Restore" : "Dismiss",
                    systemImage: reminder.isDismissed ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(reminder.isDismissed ? .orange : Color.successGreen)
        }
    }
    
    // MARK: - Helpers
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - RemindAtLabelView
struct RemindAtLabelView: View {
    let date: Date
    let isDismissed: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(dateString)
                .font(.caption2)
        }
        .fontWeight(.medium)
        .foregroundStyle(textColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var isOverdue: Bool {
        date < Date() && !isDismissed
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var iconName: String {
        if isOverdue {
            return "exclamationmark.triangle.fill"
        } else if isToday {
            return "calendar.badge.clock"
        } else {
            return "calendar"
        }
    }
    
    private var textColor: Color {
        if isOverdue {
            return .red
        } else if isToday {
            return .orange
        } else {
            return Color.brandPrimaryEnd
        }
    }
    
    private var backgroundColor: Color {
        if isOverdue {
            return Color.red.opacity(0.1)
        } else if isToday {
            return Color.orange.opacity(0.1)
        } else {
            return Color.brandPrimaryEnd.opacity(0.1)
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        if isToday {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: date))"
        } else if Calendar.current.isDateInTomorrow(date) {
            formatter.timeStyle = .short
            return "Tomorrow at \(formatter.string(from: date))"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE 'at' h:mm a"
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}
