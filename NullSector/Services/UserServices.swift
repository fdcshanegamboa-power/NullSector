//
//  UserService.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
}

class UserService: UserServiceProtocol {
    func fetchUsers() async throws -> [User] {
        // Real API call logic would go here
        return [
            User(name: "Alice", age: 30, email: "alice@icloud.com"),
            User(name: "Bob", age: 25, email: "bob@icloud.com"),
            User(name: "Charlie", age: 35, email: "charlie@icloud.com")
        ]
    }
}
