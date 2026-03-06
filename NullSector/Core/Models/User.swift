//
//  User.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation

/// Represents a user in the application
struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let createdAt: Date?
    
    /// Returns the display name for the user (email prefix before @)
    var displayName: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    /// Returns the user's initials from their email
    var initials: String {
        let components = email.components(separatedBy: "@").first ?? email
        let parts = components.components(separatedBy: ".")
        
        if parts.count >= 2 {
            // If email has format firstname.lastname, use first letters
            return parts.prefix(2)
                .compactMap { $0.first }
                .map { String($0).uppercased() }
                .joined()
        } else {
            // Otherwise, use first two letters of email prefix
            return String(components.prefix(2)).uppercased()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case createdAt = "created_at"
    }
}
