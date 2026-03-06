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
            Color.backgroundLight.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // MARK: - Hero Card
                    heroCard

                    // MARK: - Description Card
                    if let description = viewModel.task.description, !description.isEmpty {
                        descriptionCard(description)
                    }

                    // MARK: - Details Card
                    if hasAnyDetail {
                        detailsCard
                    }

                    // MARK: - Action Button
                    completionButton

                    Spacer().frame(height: 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }

            // MARK: - Loading Overlay
            if viewModel.isLoading {
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
        .navigationTitle("Task Details")
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
                    .background(Color.brandPrimaryEnd.opacity(0.1))
                    .clipShape(Capsule())
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

    // MARK: - Hero Card
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Status pill
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.task.isCompleted ? Color.successGreen : Color.brandPrimaryEnd)
                        .frame(width: 8, height: 8)
                    Text(viewModel.task.isCompleted ? "Completed" : "In Progress")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(viewModel.task.isCompleted ? Color.successGreen : Color.brandPrimaryEnd)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (viewModel.task.isCompleted ? Color.successGreen : Color.brandPrimaryEnd)
                        .opacity(0.1)
                )
                .clipShape(Capsule())

                Spacer()

                // Priority badge if set
                if let priority = viewModel.task.priority {
                    PriorityBadgeView(priority: priority)
                }
            }

            // Title
            Text(viewModel.task.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .strikethrough(viewModel.task.isCompleted, color: Color.textSecondary)
                .opacity(viewModel.task.isCompleted ? 0.7 : 1.0)

            // Due date inline if set
            if let dueDate = viewModel.task.dueDate {
                let isOverdue = dueDate < Date() && !viewModel.task.isCompleted
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                    Text(formatDate(dueDate))
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
        }
        .padding(20)
        .brandCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Description Card
    private func descriptionCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "text.alignleft", title: "Description")

            Text(text)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .brandCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Details Card
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "info.circle.fill", title: "Details")

            VStack(spacing: 10) {
                if let dueDate = viewModel.task.dueDate {
                    DetailRow(
                        icon: "calendar",
                        title: "Due Date",
                        value: formatDate(dueDate),
                        isOverdue: dueDate < Date() && !viewModel.task.isCompleted,
                        iconColor: Color.brandPrimaryEnd
                    )
                }

                if let reminderAt = viewModel.task.reminderAt {
                    DetailRow(
                        icon: "bell.fill",
                        title: "Reminder",
                        value: formatDate(reminderAt),
                        iconColor: .purple
                    )
                }

                DetailRow(
                    icon: "plus.circle.fill",
                    title: "Created",
                    value: formatDate(viewModel.task.createdAt),
                    iconColor: Color.successGreen
                )

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
    }

    // MARK: - Completion Button
    private var completionButton: some View {
        Button {
            Task {
                await viewModel.toggleCompletion()
                await onUpdate()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: viewModel.task.isCompleted
                      ? "arrow.uturn.backward.circle.fill"
                      : "checkmark.circle.fill")
                    .font(.system(size: 18))

                Text(viewModel.task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.task.isCompleted
                    ? LinearGradient(colors: [.orange, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.successGreen, Color.successGreen.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: (viewModel.task.isCompleted ? Color.orange : Color.successGreen).opacity(0.35),
                radius: 10,
                y: 5
            )
            .opacity(viewModel.isTogglingCompletion ? 0.6 : 1.0)
        }
        .disabled(viewModel.isTogglingCompletion)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Helpers
    private var hasAnyDetail: Bool {
        viewModel.task.dueDate != nil ||
        viewModel.task.reminderAt != nil ||
        viewModel.task.updatedAt != nil
    }

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

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var isOverdue: Bool = false
    var iconColor: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isOverdue ? .red : Color.textPrimary)
            }

            Spacer()

            if isOverdue {
                Text("Overdue")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.12))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(iconColor.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}