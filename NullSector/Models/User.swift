//
//  User.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//

import Foundation

struct User: Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var email: String
    var isVerified: Bool = false
}

