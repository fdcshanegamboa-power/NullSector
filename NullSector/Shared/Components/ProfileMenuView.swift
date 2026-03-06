//
//  ProfileMenuView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

/// A reusable profile menu component that displays user information
/// and provides a sign-out action
struct ProfileMenuView: View {
    let user: User?
    let onSignOut: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
        Menu {
            // User Info Section
            if let user = user {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
            }
            
            // Sign Out Action
            Button(role: .destructive, action: onSignOut) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            profileButton
        }
    }
    
    // MARK: - Profile Button
    private var profileButton: some View {
        HStack(spacing: 8) {
            // Avatar Circle with Initials
            ZStack {
                Circle()
                    .fill(Color.brandGradient)
                    .frame(width: 32, height: 32)
                
                Text(user?.initials ?? "U")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Dropdown indicator
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ProfileMenuView(
            user: User(
                id: UUID(),
                email: "john.doe@example.com",
                createdAt: Date()
            ),
            onSignOut: {}
        )
        
        ProfileMenuView(
            user: User(
                id: UUID(),
                email: "test@example.com",
                createdAt: Date()
            ),
            onSignOut: {}
        )
        
        ProfileMenuView(
            user: nil,
            onSignOut: {}
        )
    }
    .padding()
}
