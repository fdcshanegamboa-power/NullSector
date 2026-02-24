//
//  UserViewModel.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//

import Foundation

@Observable class UserViewModel {
    var users: [User] = []
    var isLoading = false
    
    private let repository: UserRepository

    init(repository: UserRepository = UserRepository()) {
        self.repository = repository
    }

    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false } // Runs when function finishes
        
        do {
            self.users = try await repository.getUsers()
        } catch {
            print("Error loading users: \(error)")
        }
    }
}
