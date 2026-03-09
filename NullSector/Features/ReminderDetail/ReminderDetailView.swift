//
//  ReminderDetailView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import SwiftUI

struct ReminderDetailView: View {
    
    @State private var viewModel: ReminderDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    
    let onUpdate: () async -> Void
    
    init(reminder: Reminder, onUpdate: @escaping () async -> Void) {
        _viewModel = State(initialValue: ReminderDetailViewModel(reminderId: reminder.id))
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        ZStack {
            Color.backgroundLight.ignoresSafeArea()
            
            if let reminder = viewModel.reminder {
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // MARK: - Hero Card
                        heroCard(reminder: reminder)
                        
                        // MARK: - Details Card
                        detailsCard(reminder: reminder)
                        
                        // MARK: - Action Buttons
                        if reminder.isDismissed {
                            restoreButton
                        } else {
                            dismissButton
                        }
                        
                        // MARK: - Delete Button
                        deleteButton
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.brandPrimaryEnd)
            } else if viewModel.errorMessage != nil {
                errorView
            }
            
            // MARK: - Loading Overlay
            if viewModel.isLoading && viewModel.reminder != nil {
                Color.black.opacity(0.25).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(Color.brandPrimaryEnd)
                    Text("Updating...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(28)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.15), radius: 20)
            }
        }
        .navigationTitle("Reminder Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Edit")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.brandPrimaryEnd)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Capsule())
                }
                .disabled(viewModel.reminder == nil)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let reminder = viewModel.reminder {
                ReminderFormView(reminder: reminder) {
                    await viewModel.fetchReminder()
                    await onUpdate()
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .confirmationDialog(
            "Delete Reminder",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.confirmDelete()
                    if viewModel.isDeleted {
                        await onUpdate()
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelDelete()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .task {
            await viewModel.fetchReminder()
        }
    }
    
    // MARK: - Hero Card
    private func heroCard(reminder: Reminder) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Status pill
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(reminder.isDismissed ? Color.textSecondary : Color.brandPrimaryEnd)
                        .frame(width: 8, height: 8)
                    Text(reminder.isDismissed ? "Dismissed" : "Active")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(reminder.isDismissed ? Color.textSecondary : Color.brandPrimaryEnd)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (reminder.isDismissed ? Color.textSecondary : Color.brandPrimaryEnd)
                        .opacity(0.1)
                )
                .clipShape(Capsule())
                
                Spacer()
                
                // Recurring indicator
                if reminder.isRecurring {
                    HStack(spacing: 6) {
                        Image(systemName: "repeat")
                            .font(.system(size: 12))
                        Text(reminder.recurrenceRule?.rawValue.capitalized ?? "")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.brandPrimaryEnd.opacity(0.12))
                    .frame(width: 60, height: 60)
                Image(systemName: reminder.isDismissed ? "checkmark.circle.fill" : "bell.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(reminder.isDismissed ? Color.textSecondary : Color.brandPrimaryEnd)
            }
            
            // Message
            Text(reminder.message)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .strikethrough(reminder.isDismissed, color: Color.textSecondary)
                .opacity(reminder.isDismissed ? 0.7 : 1.0)
            
            // Remind at inline
            let isOverdue = reminder.remindAt < Date() && !reminder.isDismissed
            HStack(spacing: 6) {
                Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "calendar.badge.clock")
                    .font(.system(size: 13))
                Text(formatDate(reminder.remindAt))
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isOverdue ? .red : Color.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                (isOverdue ? Color.red : Color.textSecondary).opacity(0.08)
            )
            .clipShape(Capsule())
        }
        .padding(20)
        .brandCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Details Card
    private func detailsCard(reminder: Reminder) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "info.circle.fill", title: "Details")
            
            VStack(spacing: 10) {
                DetailRow(
                    icon: "calendar.badge.clock",
                    title: "Remind At",
                    value: formatDate(reminder.remindAt),
                    isOverdue: reminder.remindAt < Date() && !reminder.isDismissed,
                    iconColor: Color.brandPrimaryEnd
                )
                
                if reminder.isRecurring {
                    if let rule = reminder.recurrenceRule {
                        DetailRow(
                            icon: "repeat",
                            title: "Recurrence",
                            value: rule.rawValue.capitalized,
                            iconColor: .purple
                        )
                    }
                    
                    if let endsAt = reminder.recurrenceEndsAt {
                        DetailRow(
                            icon: "calendar.badge.exclamationmark",
                            title: "Recurrence Ends",
                            value: formatDate(endsAt),
                            iconColor: .orange
                        )
                    } else {
                        DetailRow(
                            icon: "infinity",
                            title: "Recurrence",
                            value: "Repeats forever",
                            iconColor: .purple
                        )
                    }
                }
                
                DetailRow(
                    icon: "plus.circle.fill",
                    title: "Created",
                    value: formatDate(reminder.createdAt),
                    iconColor: Color.successGreen
                )
                
                if let updatedAt = reminder.updatedAt {
                    DetailRow(
                        icon: "arrow.clockwise.circle.fill",
                        title: "Last Updated",
                        value: formatDate(updatedAt),
                        iconColor: .orange
                    )
                }
            }
        }
        .padding(20)
        .brandCard()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Dismiss Button
    private var dismissButton: some View {
        Button {
            Task {
                await viewModel.dismissReminder()
                await onUpdate()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                
                Text("Dismiss Reminder")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color.successGreen, Color.successGreen.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: Color.successGreen.opacity(0.35),
                radius: 10,
                y: 5
            )
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
    
    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            Task {
                await viewModel.restoreReminder()
                await onUpdate()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 18))
                
                Text("Restore Reminder")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: Color.orange.opacity(0.35),
                radius: 10,
                y: 5
            )
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
    
    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            viewModel.requestDelete()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                
                Text("Delete Reminder")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            
            Text("Failed to load reminder")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.fetchReminder()
                }
            } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.brandPrimaryEnd)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func sectionHeader(icon: String, title: String) -> some View {
        Label {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.brandPrimaryEnd)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
