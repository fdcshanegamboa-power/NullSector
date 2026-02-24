//
//  UserRepository.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//
import Foundation
class UserRepository {
    private let service: UserServiceProtocol

    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }

    func getUsers() async throws -> [User] {
        // Logic: "If I have cached data, return that. Otherwise, call the service."
        return try await service.fetchUsers()
    }
}
