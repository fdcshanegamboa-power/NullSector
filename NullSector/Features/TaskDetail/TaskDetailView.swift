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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Header Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.task.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            HStack(spacing: 12) {
                                // Priority Badge
                                if let priority = viewModel.task.priority {
                                    PriorityBadgeView(priority: priority)
                                }

                                // Completion Status
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(viewModel.task.isCompleted ? .green : .secondary)
                                    Text(viewModel.task.isCompleted ? "Completed" : "Incomplete")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(viewModel.task.isCompleted ? .green : .secondary)
                                }
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
                            Image(systemName: viewModel.task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.task.isCompleted ? .orange : .green)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // MARK: - Description Section
                if let description = viewModel.task.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "text.alignleft")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Details", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 12) {
                        // Due Date
                        if let dueDate = viewModel.task.dueDate {
                            DetailRow(
                                icon: "calendar",
                                title: "Due Date",
                                value: formatDate(dueDate),
                                isOverdue: dueDate < Date() && !viewModel.task.isCompleted,
                                iconColor: .blue
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
                            icon: "plus.circle",
                            title: "Created",
                            value: formatDate(viewModel.task.createdAt),
                            iconColor: .green
                        )

                        // Updated Date
                        if let updatedAt = viewModel.task.updatedAt {
                            DetailRow(
                                icon: "arrow.clockwise.circle",
                                title: "Last Updated",
                                value: formatDate(updatedAt),
                                iconColor: .orange
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Text("Edit")
                        .fontWeight(.semibold)
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isOverdue ? .red : .primary)
            }

            Spacer()

            if isOverdue {
                Text("Overdue")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
            }
        }
    }
}
