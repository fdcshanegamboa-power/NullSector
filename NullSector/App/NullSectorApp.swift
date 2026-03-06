//
//  NullSectorApp.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//

import SwiftUI

@main
struct NullSectorApp: App {
    @State private var authViewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn {
                    TaskListView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .task {
                await authViewModel.checkSession()
                await NotificationService.shared.requestPermission()
            }
        }
    }
}
