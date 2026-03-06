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
                
                Form {

                    // MARK: - Title
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textSecondary)
                            
                            TextField("What needs to be done?", text: $viewModel.title)
                                .font(.body)
                                .textFieldStyle(.plain)
                        }
                        .listRowBackground(Color.cardBackground)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (optional)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textSecondary)
                            
                            TextField("Add more details...", text: $viewModel.description, axis: .vertical)
                                .font(.body)
                                .textFieldStyle(.plain)
                                .lineLimit(3...6)
                        }
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Label("Task Information", systemImage: "doc.text.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                    }

                    // MARK: - Priority
                    Section {
                        Picker("Priority", selection: $viewModel.priority) {
                            Text("None").tag(Optional<Priority>.none)
                            ForEach(Priority.allCases, id: \.self) { priority in
                                HStack {
                                    Circle()
                                        .fill(priorityColor(priority))
                                        .frame(width: 8, height: 8)
                                    Text(priority.label)
                                }
                                .tag(Optional(priority))
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.cardBackground)
                    } header: {
                        Label("Priority Level", systemImage: "flag.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                    }

                    // MARK: - Due Date
                    Section {
                        Toggle(isOn: $viewModel.hasDueDate) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color.brandPrimaryEnd)
                                Text("Set due date")
                                    .fontWeight(.medium)
                            }
                        }
                        .tint(Color.brandPrimaryEnd)
                        .listRowBackground(Color.cardBackground)

                        if viewModel.hasDueDate {
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
                            .listRowBackground(Color.cardBackground)
                        }
                    } header: {
                        Label("Schedule", systemImage: "calendar.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                    }

                    // MARK: - Reminder
                    Section {
                        Toggle(isOn: $viewModel.hasReminder) {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.purple)
                                Text("Set reminder")
                                    .fontWeight(.medium)
                            }
                        }
                        .tint(.purple)
                        .disabled(!viewModel.hasDueDate)
                        .listRowBackground(Color.cardBackground)

                        if viewModel.hasReminder && viewModel.hasDueDate {
                            DatePicker(
                                "Remind me at",
                                selection: Binding(
                                    get: { viewModel.reminderAt ?? Date() },
                                    set: { viewModel.reminderAt = $0 }
                                ),
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .listRowBackground(Color.cardBackground)
                        }

                        if !viewModel.hasDueDate {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(Color.textSecondary)
                                Text("Set a due date first to enable reminders.")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .listRowBackground(Color.cardBackground)
                        }
                    } header: {
                        Label("Notifications", systemImage: "bell.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.textPrimary)
                    }

                    // MARK: - Error
                    if let error = viewModel.errorMessage {
                        Section {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            .listRowBackground(Color.red.opacity(0.1))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                // Saving overlay
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color.brandPrimaryEnd)
                            
                            Text("Saving task...")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.textPrimary)
                        }
                        .padding(32)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.2), radius: 20)
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // MARK: - Cancel
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Cancel")
                        }
                        .foregroundStyle(Color.textSecondary)
                    }
                    .disabled(viewModel.isLoading)
                }

                // MARK: - Save
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.save()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save")
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                                ? Color.textSecondary
                                : Color.brandPrimaryEnd
                        )
                    }
                    .disabled(viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
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
    
    // MARK: - Helper Functions
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
