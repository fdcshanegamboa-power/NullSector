//
//  Color+Theme.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let brandPrimaryStart = Color(red: 0.31, green: 0.27, blue: 0.90)
    static let brandPrimaryEnd = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimaryStart, brandPrimaryEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Text Colors
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.62)
    
    // MARK: - Background Colors
    static let backgroundLight = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let cardBackground = Color.white
    static let inputBackground = Color(red: 0.97, green: 0.97, blue: 0.99)
    
    // MARK: - Status Colors
    static let successGreen = Color(red: 0.18, green: 0.75, blue: 0.45)
}

// MARK: - View Modifiers
extension View {
    func brandCard() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
    
    func brandButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.brandGradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.brandPrimaryEnd.opacity(0.35), radius: 12, y: 6)
    }
}
