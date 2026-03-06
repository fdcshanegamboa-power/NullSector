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
            Form {

                // MARK: - Title
                Section("Task") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Description (optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                // MARK: - Priority
                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priority) {
                        Text("None").tag(Optional<Priority>.none)
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.label).tag(Optional(priority))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Due Date
                Section("Due Date") {
                    Toggle("Set due date", isOn: $viewModel.hasDueDate)

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
                    }
                }

                // MARK: - Reminder
                Section("Reminder") {
                    Toggle("Set reminder", isOn: $viewModel.hasReminder)
                        .disabled(!viewModel.hasDueDate)

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
                    }

                    if !viewModel.hasDueDate {
                        Text("Set a due date first to enable reminders.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // MARK: - Cancel
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // MARK: - Save
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .fontWeight(.semibold)
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
}
