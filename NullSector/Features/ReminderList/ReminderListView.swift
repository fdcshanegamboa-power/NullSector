//
//  ReminderListView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import SwiftUI

struct ReminderListView: View {

    @State private var viewModel = ReminderListViewModel()
    @State private var showAddReminder: Bool = false
    @State private var reminderToEdit: Reminder? = nil
    @State private var selectedReminder: Reminder? = nil
    

    var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.backgroundLight.ignoresSafeArea()

            Group {
                if viewModel.isLoading && viewModel.reminders.isEmpty {
                    loadingView
                } else if viewModel.reminders.isEmpty {
                    emptyStateView
                } else {
                    reminderList
                }
            }

            // MARK: - Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.brandGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.brandPrimaryEnd.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("My Reminders")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // MARK: - Profile Menu
            ToolbarItem(placement: .topBarLeading) {
                ProfileMenuView(user: authViewModel.currentUser) {
                    Task { await authViewModel.signOut() }
                }
            }

            // MARK: - Filter + Sort Menu
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle(isOn: $viewModel.showDismissed) {
                        Label("Show Dismissed", systemImage: viewModel.showDismissed ? "checkmark.circle.fill" : "checkmark.circle")
                    }
                    .onChange(of: viewModel.showDismissed) {
                        Task { await viewModel.fetchReminders() }
                    }

                    Divider()

                    Menu {
                        ForEach(ReminderListViewModel.SortOption.allCases) { option in
                            Button {
                                viewModel.sortOption = option
                                Task { await viewModel.fetchReminders() }
                            } label: {
                                Label(
                                    option.rawValue,
                                    systemImage: viewModel.sortOption == option
                                        ? "checkmark" : option.systemImage
                                )
                            }
                        }
                    } label: {
                        Label("Sort By", systemImage: "arrow.up.arrow.down")
                    }

                } label: {
                    let isFiltered = viewModel.showDismissed || viewModel.sortOption != .remindAtAsc
                    Image(systemName: isFiltered
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundStyle(Color.brandPrimaryEnd)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search reminders")
        .onChange(of: viewModel.searchText) {
            Task { await viewModel.fetchReminders() }
        }
        .refreshable {
            await viewModel.fetchReminders()
        }
        .sheet(item: $reminderToEdit) { reminder in
            ReminderFormView(reminder: reminder) { await viewModel.fetchReminders() }
        }
        .sheet(isPresented: $showAddReminder) {
            ReminderFormView { await viewModel.fetchReminders() }
        }
        .navigationDestination(item: $selectedReminder) { reminder in
            ReminderDetailView(reminder: reminder) { await viewModel.fetchReminders() }
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
            Button("Delete Reminder", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
        } message: {
            Text("This action cannot be undone.")
        }
        .task {
            await viewModel.fetchReminders()
        }
    }

    // MARK: - Reminder List
    private var reminderList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.reminders) { reminder in
                    ReminderRowView(
                        reminder: reminder,
                        onDismiss: { Task { await viewModel.dismissReminder(reminder) } },
                        onRestore: { Task { await viewModel.restoreReminder(reminder) } },
                        onEdit: { reminderToEdit = reminder },
                        onDelete: { viewModel.requestDelete(reminder) }
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedReminder = reminder }
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

                Image(systemName: "bell.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.brandGradient)
            }

            VStack(spacing: 8) {
                Text("No Reminders Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Tap the + button to create your first reminder\nand never forget important things.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showAddReminder = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Reminder").fontWeight(.semibold)
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

            Text("Loading reminders...")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }
}