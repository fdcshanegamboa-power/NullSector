//
//  ReminderFormView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/9/26.
//

import SwiftUI

struct ReminderFormView: View {
    
    @State private var viewModel: ReminderFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    let onSave: () async -> Void
    
    init(
        reminder: Reminder? = nil,
        onSave: @escaping () async -> Void
    ) {
        _viewModel = State(initialValue: ReminderFormViewModel(reminder: reminder))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // MARK: - Reminder Info Card
                        formCard {
                            VStack(alignment: .leading, spacing: 16) {
                                formSectionHeader(icon: "bell.fill", title: "Reminder Information")
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    fieldLabel("Message")
                                    TextField("What should I remind you about?", text: $viewModel.message, axis: .vertical)
                                        .font(.body)
                                        .lineLimit(2...4)
                                        .padding(12)
                                        .background(Color.backgroundLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.brandPrimaryEnd.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    fieldLabel("Remind At")
                                    DatePicker(
                                        "Remind me at",
                                        selection: $viewModel.remindAt,
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(Color.brandPrimaryEnd)
                                }
                            }
                        }
                        
                        // MARK: - Recurrence Card
                        formCard {
                            VStack(alignment: .leading, spacing: 14) {
                                formSectionHeader(icon: "repeat", title: "Recurrence")
                                
                                HStack {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.purple.opacity(0.12))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "repeat")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.purple)
                                        }
                                        Text("Recurring reminder")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.textPrimary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.isRecurring)
                                        .tint(.purple)
                                        .labelsHidden()
                                }
                                
                                if viewModel.isRecurring {
                                    Divider()
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        fieldLabel("Repeat Every")
                                        
                                        Picker("Recurrence Rule", selection: $viewModel.recurrenceRule) {
                                            ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                                                Text(rule.rawValue.capitalized).tag(rule as RecurrenceRule?)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        HStack(spacing: 10) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.orange.opacity(0.12))
                                                    .frame(width: 32, height: 32)
                                                Image(systemName: "calendar.badge.clock")
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(.orange)
                                            }
                                            Text("End date")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(Color.textPrimary)
                                        }
                                        Spacer()
                                        Toggle("", isOn: $viewModel.hasRecurrenceEnd)
                                            .tint(.orange)
                                            .labelsHidden()
                                    }
                                    
                                    if viewModel.hasRecurrenceEnd {
                                        Divider()
                                        
                                        DatePicker(
                                            "Ends on",
                                            selection: $viewModel.recurrenceEndsAt,
                                            in: viewModel.remindAt...,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)
                                        .tint(.orange)
                                    }
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
                        Text("Saving reminder...")
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
            .navigationTitle(viewModel.isEditing ? "Edit Reminder" : "New Reminder")
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
                                viewModel.message.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                                    ? Color.textSecondary.opacity(0.4)
                                    : Color.brandPrimaryEnd
                            )
                            .clipShape(Capsule())
                    }
                    .disabled(
                        viewModel.message.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                    )
                }
            }
            .onChange(of: viewModel.isSaved) {
                if viewModel.isSaved {
                    Task {
                        await onSave()
                        dismiss()
                    }
                }
            }
        }
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
