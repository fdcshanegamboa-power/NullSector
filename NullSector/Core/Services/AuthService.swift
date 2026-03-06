//
//  AuthService.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation
import Supabase

@MainActor
class AuthService {
    
    func signUp(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        try await supabase.auth.signUp(
            email: email,
            password: password
        )
    }

    func signIn(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        guard !password.isEmpty else {
            throw AuthError.emptyPassword
        }

        try await supabase.auth.signIn(
            email: email,
            password: password
        )
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    func getCurrentUser() async -> User? {
        do {
            let session = try await supabase.auth.session
            return User(
                id: session.user.id,
                email: session.user.email ?? "unknown@example.com",
                createdAt: session.user.createdAt
            )
        } catch {
            return nil
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emptyPassword
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 8 characters long."
        case .emptyPassword:
            return "Password cannot be empty."
        }
    }
}
