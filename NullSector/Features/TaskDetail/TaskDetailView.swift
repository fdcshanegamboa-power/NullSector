//
//  TaskDetailView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct TaskDetailView: View {

    @State private var viewModel: TaskDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false

    let onUpdate: () async -> Void

    init(task: TodoTask, onUpdate: @escaping () async -> Void) {
        _viewModel = State(initialValue: TaskDetailViewModel(task: task))
        self.onUpdate = onUpdate
    }

    var body: some View {
        ZStack {
            // Background
            Color.backgroundLight.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(viewModel.task.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.textPrimary)

                                HStack(spacing: 12) {
                                    // Priority Badge
                                    if let priority = viewModel.task.priority {
                                        PriorityBadgeView(priority: priority)
                                    }

                                    // Completion Status
                                    HStack(spacing: 6) {
                                        Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 16))
                                            .foregroundStyle(viewModel.task.isCompleted ? Color.successGreen : Color.textSecondary)
                                        Text(viewModel.task.isCompleted ? "Completed" : "Incomplete")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(viewModel.task.isCompleted ? Color.successGreen : Color.textSecondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        (viewModel.task.isCompleted ? Color.successGreen : Color.gray)
                                            .opacity(0.1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }

                            Spacer()

                            // Toggle Completion Button
                            Button {
                                Task {
                                    await viewModel.toggleCompletion()
                                    await onUpdate()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            viewModel.task.isCompleted 
                                                ? Color.orange.opacity(0.15) 
                                                : Color.successGreen.opacity(0.15)
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: viewModel.task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(viewModel.task.isCompleted ? .orange : Color.successGreen)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isTogglingCompletion)
                            .opacity(viewModel.isTogglingCompletion ? 0.6 : 1.0)
                        }
                    }
                    .padding(20)
                    .brandCard()
                    .padding(.horizontal, 16)
                    .padding(.horizontal, 16)

                // MARK: - Description Section
                if let description = viewModel.task.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Description")
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)
                        } icon: {
                            Image(systemName: "text.alignleft")
                                .foregroundStyle(Color.brandPrimaryEnd)
                        }

                        Text(description)
                            .font(.body)
                            .foregroundStyle(Color.textPrimary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .brandCard()
                    .padding(.horizontal, 16)
                }

                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Label {
                        Text("Details")
                            .font(.headline)
                            .foregroundStyle(Color.textPrimary)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.brandPrimaryEnd)
                    }

                    VStack(spacing: 16) {
                        // Due Date
                        if let dueDate = viewModel.task.dueDate {
                            DetailRow(
                                icon: "calendar",
                                title: "Due Date",
                                value: formatDate(dueDate),
                                isOverdue: dueDate < Date() && !viewModel.task.isCompleted,
                                iconColor: Color.brandPrimaryEnd
                            )
                        }

                        // Reminder
                        if let reminderAt = viewModel.task.reminderAt {
                            DetailRow(
                                icon: "bell.fill",
                                title: "Reminder",
                                value: formatDate(reminderAt),
                                iconColor: .purple
                            )
                        }

                        // Created Date
                        DetailRow(
                            icon: "plus.circle.fill",
                            title: "Created",
                            value: formatDate(viewModel.task.createdAt),
                            iconColor: Color.successGreen
                        )

                        // Updated Date
                        if let updatedAt = viewModel.task.updatedAt {
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
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.vertical, 20)
        }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.circle.fill")
                        Text("Edit")
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.brandPrimaryEnd)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            TaskFormView(task: viewModel.task) {
                await viewModel.fetchTask()
                await onUpdate()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color.brandPrimaryEnd)
                        Text("Updating...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 20)
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var isOverdue: Bool = false
    var iconColor: Color = .blue

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isOverdue ? .red : Color.textPrimary)
            }

            Spacer()

            if isOverdue {
                Text("Overdue")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(iconColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
