//
//  CalendarDayCell.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftUI

/// Individual calendar day cell component
struct CalendarDayCell: View {
  let day: Int
  let isCurrentMonth: Bool
  let isToday: Bool
  let isSelected: Bool
  let totalSpending: Double
  let hasSubscriptionPayment: Bool
  let categoryColors: [Color]

  var body: some View {
    VStack(spacing: 4) {
      // Day number
      Text("\(day)")
        .font(.system(size: 16, weight: isToday ? .bold : .regular))
        .foregroundStyle(dayTextColor)

      // Spending indicator dots
      if !categoryColors.isEmpty || hasSubscriptionPayment {
        HStack(spacing: 2) {
          ForEach(Array(categoryColors.prefix(3).enumerated()), id: \.offset) { _, color in
            Circle()
              .fill(color)
              .frame(width: 4, height: 4)
          }

          if hasSubscriptionPayment {
            Circle()
              .fill(Color.orange)
              .frame(width: 4, height: 4)
          }
        }
      } else {
        // Spacer for consistent height
        Spacer()
          .frame(height: 4)
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: 44)
    .background {
      if isSelected {
        Circle()
          .fill(Color.accentColor)
          .frame(width: 36, height: 36)
      } else if isToday {
        Circle()
          .stroke(Color.accentColor, lineWidth: 1.5)
          .frame(width: 36, height: 36)
      }
    }
    .contentShape(Rectangle())
  }

  private var dayTextColor: Color {
    if isSelected {
      return .white
    } else if !isCurrentMonth {
      return Color.gray.opacity(0.4)
    } else if isToday {
      return .accentColor
    } else {
      return .primary
    }
  }
}

/// Empty calendar day cell for layout
struct EmptyCalendarDayCell: View {
  var body: some View {
    Color.clear
      .frame(maxWidth: .infinity)
      .frame(height: 44)
  }
}

#Preview {
  HStack(spacing: 4) {
    CalendarDayCell(
      day: 15,
      isCurrentMonth: true,
      isToday: false,
      isSelected: false,
      totalSpending: 45.50,
      hasSubscriptionPayment: false,
      categoryColors: [.orange, .blue]
    )

    CalendarDayCell(
      day: 16,
      isCurrentMonth: true,
      isToday: true,
      isSelected: false,
      totalSpending: 0,
      hasSubscriptionPayment: false,
      categoryColors: []
    )

    CalendarDayCell(
      day: 17,
      isCurrentMonth: true,
      isToday: false,
      isSelected: true,
      totalSpending: 120.00,
      hasSubscriptionPayment: true,
      categoryColors: [.purple, .green, .red]
    )
  }
  .padding()
  .background(Color(.systemGroupedBackground))
}
