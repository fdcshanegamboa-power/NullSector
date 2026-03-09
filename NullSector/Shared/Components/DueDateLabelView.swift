//
//  DueDateLabelView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 3/6/26.
//

import SwiftUI

struct DueDateLabelView: View {

    let date: Date
    var isCompleted: Bool = false

    private var isOverdue: Bool {
        !isCompleted && date < Date()
    }

    private var isDueToday: Bool {
        !isCompleted && Calendar.current.isDateInToday(date)
    }

    private var formatted: String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        }
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "calendar")
                .font(.system(size: 10))
            Text(formatted)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(
            isOverdue ? .red :
            isDueToday ? Color.brandPrimaryEnd :
            Color.textSecondary
        )
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            (isOverdue ? Color.red :
             isDueToday ? Color.brandPrimaryEnd :
             Color.textSecondary).opacity(0.08)
        )
        .clipShape(Capsule())
    }
}
