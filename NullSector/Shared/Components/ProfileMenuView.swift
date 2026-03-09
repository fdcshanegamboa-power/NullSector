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
    
    var body: some View {
        Menu {
            // User Info Section
            if let user = user {
                Text(user.displayName)
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
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
        HStack(spacing: 6) {
            // Avatar Circle with Initials
            ZStack {
                Circle()
                    .fill(Color.brandPrimaryEnd.opacity(0.15))
                    .frame(width: 30, height: 30)
                
                Text(user?.initials ?? "U")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.brandPrimaryEnd)
            }
            
            // Dropdown indicator
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.brandPrimaryEnd)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.brandPrimaryEnd.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brandPrimaryEnd.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Simulated navbar background for accurate preview
        ZStack {
            LinearGradient(
                colors: [Color.brandPrimaryStart, Color.brandPrimaryEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 60)
            
            ProfileMenuView(
                user: User(id: UUID(), email: "john.doe@example.com", createdAt: Date()),
                onSignOut: {}
            )
        }
        
        ZStack {
            LinearGradient(
                colors: [Color.brandPrimaryStart, Color.brandPrimaryEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 60)
            
            ProfileMenuView(user: nil, onSignOut: {})
        }
    }
    .padding()
}