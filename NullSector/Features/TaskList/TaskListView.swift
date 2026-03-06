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
            ZStack {
                // Background
                Color.backgroundLight.ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading && viewModel.tasks.isEmpty {
                        loadingView
                    } else if viewModel.tasks.isEmpty {
                        emptyStateView
                    } else {
                        taskList
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                // MARK: - Add Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.brandPrimaryEnd)
                    }
                }

                // MARK: - Sign Out Button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                    }
                }

                // MARK: - Filter Toggle
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 12) {
                        Toggle(isOn: $viewModel.showCompleted) {
                            Label("Show Completed", systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .tint(Color.brandPrimaryEnd)
                        .onChange(of: viewModel.showCompleted) {
                            Task { await viewModel.fetchTasks() }
                        }
                        
                        if viewModel.isLoading && !viewModel.tasks.isEmpty {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task) {
                        Task {
                            await viewModel.toggleCompletion(task: task)
                        }
                    }
                    .brandCard()
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTask = task
                    }
                    .contextMenu {
                        Button {
                            taskToEdit = task
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteTask(task)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.brandGradient)
                    .frame(width: 120, height: 120)
                    .opacity(0.15)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.brandGradient)
            }

            VStack(spacing: 8) {
                Text("No Tasks Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Tap the + button to add your first task\nand start organizing your day.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button {
                showAddTask = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Task")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.brandGradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.brandPrimaryEnd.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.brandPrimaryEnd)
            
            Text("Loading tasks...")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
