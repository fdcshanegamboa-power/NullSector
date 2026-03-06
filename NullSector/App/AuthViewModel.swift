//
//  AuthViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import Foundation
import Supabase
import Observation

@MainActor
@Observable
class AuthViewModel {
    var isLoggedIn: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var currentUser: User? = nil
    
    private let authService: AuthService
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }
    
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            currentUser = User(
                id: session.user.id,
                email: session.user.email ?? "unknown@example.com",
                createdAt: session.user.createdAt
            )
            isLoggedIn = true
        } catch {
            isLoggedIn = false
            currentUser = nil
        }
    }
    
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await authService.signUp(email: email, password: password)
            await checkSession() // Fetch user data after sign up
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.signIn(email: email, password: password)
            await checkSession() // Fetch user data after sign in
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.signOut()
            isLoggedIn = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
