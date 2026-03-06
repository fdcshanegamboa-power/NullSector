//
//  ContentView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//
//
import SwiftUI
import Foundation
import Supabase


struct ContentView: View {

    @State private var statusMessage = "Checking connection..."

    var body: some View {
        Text(statusMessage)
            .padding()
            .task {
                await testConnection()
            }
    }

    func testConnection() async {
        do {
            // Tries to get the current session — will be nil if no user is logged in
            // but it still confirms the client initialised correctly
            let session = try await supabase.auth.session
            statusMessage = "Connected! User: \(session.user.email ?? "unknown")"
        } catch {
            // No session just means no one is logged in — that's fine
            statusMessage = "Supabase connected. No active session yet."
        }
    }
}

#Preview {
    ContentView()
}
