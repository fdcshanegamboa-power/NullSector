//
//  TaskListView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct TaskListView: View {

    @State private var viewModel = TaskListViewModel()
    @State private var showAddTask: Bool = false
    @State private var taskToEdit: TodoTask? = nil
    @State private var selectedTask: TodoTask? = nil

    var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                } else if viewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                // MARK: - Add Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                // MARK: - Sign Out Button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                    .foregroundStyle(.red)
                }

                // MARK: - Filter Toggle
                ToolbarItem(placement: .bottomBar) {
                    Toggle(isOn: $viewModel.showCompleted) {
                        Text("Show Completed")
                            .font(.subheadline)
                    }
                    .onChange(of: viewModel.showCompleted) {
                        Task { await viewModel.fetchTasks() }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .onChange(of: viewModel.searchText) {
                Task { await viewModel.fetchTasks() }
            }
            .refreshable {
                await viewModel.fetchTasks()
            }
            .sheet(item: $taskToEdit) { task in
                TaskFormView(task: task) {
                    await viewModel.fetchTasks()
                }
            }
            .sheet(isPresented: $showAddTask) {
                TaskFormView {
                    await viewModel.fetchTasks()
                }
            }
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(task: task) {
                    await viewModel.fetchTasks()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.fetchTasks()
            }
        }
    }

    // MARK: - Task List
    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task) {
                    Task {
                        await viewModel.toggleCompletion(task: task)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTask = task
                }
                .swipeActions(edge: .leading) {
                    Button{
                        taskToEdit = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteTask(task)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the + button to add your first task.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
