//
//  DueDateLabelView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct DueDateLabelView: View {

    let date: Date

    private var isOverdue: Bool {
        date < Date()
    }

    private var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
            Text(formatted)
        }
        .font(.caption2)
        .fontWeight(.medium)
        .foregroundStyle(isOverdue ? .red : .secondary)
    }
}
