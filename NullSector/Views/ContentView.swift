//
//  ContentView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//

import SwiftUI

struct ContentView: View {
    
    var authViewModel: AuthViewModel
    @State private var taskPath = NavigationPath()
    @State private var reminderPath = NavigationPath()
    
    var body: some View {
        TabView {
            NavigationStack(path: $taskPath) {
                TaskListView(authViewModel: authViewModel)
            }
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.brandPrimaryStart, Color.brandPrimaryEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Label("Tasks", systemImage: "checkmark.circle.fill")
            }
            
            NavigationStack(path: $reminderPath) {
                ReminderListView(authViewModel: authViewModel)
            }
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.brandPrimaryStart, Color.brandPrimaryEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Label("Reminders", systemImage: "bell.fill")
            }
        }
        .tint(Color.brandPrimaryEnd)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.cardBackground)

            let normalAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(Color.textSecondary)
            ]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)

            let selectedAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(Color.brandPrimaryEnd)
            ]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.brandPrimaryEnd)

            appearance.shadowColor = UIColor(Color.brandPrimaryEnd.opacity(0.15))

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}