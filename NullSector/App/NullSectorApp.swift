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
    @State private var isInitializing = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInitializing {
                    // Show splash screen during initialization
                    SplashView()
                        .transition(.opacity)
                } else {
                    // Show main app content after initialization
                    Group {
                        if authViewModel.isLoggedIn {
                            ContentView(authViewModel: authViewModel)
                        } else {
                            LoginView(authViewModel: authViewModel)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isInitializing)
            .task {
                // Initialize app
                await initializeApp()
            }
        }
    }
    
    // MARK: - App Initialization
    private func initializeApp() async {
        // Check authentication session
        await authViewModel.checkSession()
        
        // Request notification permissions
        await NotificationService.shared.requestPermission()
        
        // Add a minimum display time for splash screen (optional, for better UX)
        try? await Task.sleep(for: .milliseconds(800))
        
        // Hide splash screen
        isInitializing = false
    }
}
