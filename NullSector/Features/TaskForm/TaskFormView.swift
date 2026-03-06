//
//  TaskFormView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct TaskFormView: View {

    @State private var viewModel: TaskFormViewModel
    @Environment(\.dismiss) private var dismiss

    let onSave: () async -> Void

    init(
        task: TodoTask? = nil,
        onSave: @escaping () async -> Void
    ) {
        _viewModel = State(initialValue: TaskFormViewModel(task: task))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // MARK: - Task Info Card
                        formCard {
                            VStack(alignment: .leading, spacing: 16) {
                                formSectionHeader(icon: "doc.text.fill", title: "Task Information")

                                VStack(alignment: .leading, spacing: 6) {
                                    fieldLabel("Title")
                                    TextField("What needs to be done?", text: $viewModel.title)
                                        .font(.body)
                                        .padding(12)
                                        .background(Color.backgroundLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.brandPrimaryEnd.opacity(0.2), lineWidth: 1)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    fieldLabel("Description (optional)")
                                    TextField("Add more details...", text: $viewModel.description, axis: .vertical)
                                        .font(.body)
                                        .lineLimit(3...6)
                                        .padding(12)
                                        .background(Color.backgroundLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.brandPrimaryEnd.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                        }

                        // MARK: - Priority Card
                        formCard {
                            VStack(alignment: .leading, spacing: 14) {
                                formSectionHeader(icon: "flag.fill", title: "Priority Level")

                                HStack(spacing: 10) {
                                    priorityOption(nil, label: "None", color: Color.textSecondary)
                                    ForEach(Priority.allCases, id: \.self) { priority in
                                        priorityOption(priority, label: priority.rawValue.capitalized, color: priority.color)
                                    }
                                }
                            }
                        }

                        // MARK: - Schedule Card
                        formCard {
                            VStack(alignment: .leading, spacing: 14) {
                                formSectionHeader(icon: "calendar.circle.fill", title: "Schedule")

                                // Due Date Toggle
                                HStack {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.brandPrimaryEnd.opacity(0.12))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "calendar")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.brandPrimaryEnd)
                                        }
                                        Text("Due date")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.textPrimary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.hasDueDate)
                                        .tint(Color.brandPrimaryEnd)
                                        .labelsHidden()
                                }

                                if viewModel.hasDueDate {
                                    Divider()

                                    DatePicker(
                                        "Due",
                                        selection: Binding(
                                            get: { viewModel.dueDate ?? Date() },
                                            set: { viewModel.dueDate = $0 }
                                        ),
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(Color.brandPrimaryEnd)
                                }
                            }
                        }

                        // MARK: - Reminder Card
                        formCard {
                            VStack(alignment: .leading, spacing: 14) {
                                formSectionHeader(icon: "bell.circle.fill", title: "Reminder")

                                HStack {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.12))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "bell.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.purple)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Set reminder")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    viewModel.hasDueDate
                                                        ? Color.textPrimary
                                                        : Color.textSecondary
                                                )
                                            if !viewModel.hasDueDate {
                                                Text("Requires a due date")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.textSecondary)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.hasReminder)
                                        .tint(.purple)
                                        .labelsHidden()
                                        .disabled(!viewModel.hasDueDate)
                                }

                                if viewModel.hasReminder && viewModel.hasDueDate {
                                    Divider()

                                    DatePicker(
                                        "Remind me",
                                        selection: Binding(
                                            get: { viewModel.reminderAt ?? Date() },
                                            set: { viewModel.reminderAt = $0 }
                                        ),
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(.purple)
                                }
                            }
                        }

                        // MARK: - Error
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                        }

                        Spacer().frame(height: 8)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }

                // MARK: - Saving Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(Color.brandPrimaryEnd)
                        Text("Saving task...")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(32)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.15), radius: 20)
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Color.textSecondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isLoading)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.save() }
                    } label: {
                        Text("Save")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(
                                viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                                    ? Color.textSecondary.opacity(0.4)
                                    : Color.brandPrimaryEnd
                            )
                            .clipShape(Capsule())
                    }
                    .disabled(
                        viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                    )
                }
            }
            .onChange(of: viewModel.didSave) {
                if viewModel.didSave {
                    Task {
                        await onSave()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Priority Option Button
    private func priorityOption(_ priority: Priority?, label: String, color: Color) -> some View {
        let isSelected = viewModel.priority == priority

        return Button {
            viewModel.priority = priority
        } label: {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? color : color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reusable Helpers
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(16)
        .brandCard()
        .padding(.horizontal, 16)
    }

    private func formSectionHeader(icon: String, title: String) -> some View {
        Label {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(Color.brandPrimaryEnd)
                .font(.system(size: 14))
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}