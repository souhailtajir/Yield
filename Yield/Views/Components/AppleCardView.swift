//
//  AppleCardView.swift
//  Yield
//
//  Created on 1/10/26.
//

import SwiftUI

/// Clean MeshGradient card matching Apple Card proportions
/// Card aspect ratio: ~1.58:1 (standard credit card ratio)
struct AppleCardView: View {
  let categoryBreakdown: [CategorySpending]

  private var meshColors: [Color] {
    // Vibrant default colors with more pop
    let defaultColors: [Color] = [
      Color(red: 1.0, green: 0.6, blue: 0.2),  // Warm orange
      Color(red: 1.0, green: 0.85, blue: 0.4),  // Golden yellow
      Color(red: 0.95, green: 0.75, blue: 0.85),  // Soft pink
      Color(red: 1.0, green: 0.5, blue: 0.3),  // Coral
      Color(red: 1.0, green: 0.7, blue: 0.3),  // Amber
      Color(red: 0.9, green: 0.85, blue: 0.95),  // Light lavender
      Color(red: 1.0, green: 0.55, blue: 0.25),  // Deep orange
      Color(red: 1.0, green: 0.8, blue: 0.5),  // Peach
      Color(red: 0.85, green: 0.9, blue: 0.98),  // Ice blue
    ]

    guard !categoryBreakdown.isEmpty else { return defaultColors }

    var colors = defaultColors
    let sorted = categoryBreakdown.sorted { $0.amount > $1.amount }

    // Use full saturation for more vibrant colors
    for (index, spending) in sorted.prefix(3).enumerated() {
      let baseColor = spending.category.color
      colors[index * 3] = baseColor
      colors[index * 3 + 1] = baseColor.opacity(0.85)
    }

    return colors
  }

  var body: some View {
    ZStack {
      // Base mesh gradient with vibrant colors
      MeshGradient(
        width: 3,
        height: 3,
        points: [
          [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
          [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
          [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
        ],
        colors: meshColors
      )

      // Frosty matte overlay for premium look
      RoundedRectangle(cornerRadius: 16)
        .fill(.ultraThinMaterial)
        .opacity(0.25)
    }
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .aspectRatio(1.58, contentMode: .fit)  // Credit card ratio
  }
}

/// Remaining balance card - matches Apple Card "Card Balance" style
struct RemainingBalanceCard: View {
  let remaining: Double
  let total: Double

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Remaining")
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(remaining.formatted(.currency(code: "USD")))
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)

      Text("of \(total.formatted(.currency(code: "USD")))")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.clear)
        .glassEffect(.regular)
    }
  }
}

/// Weekly activity card - matches Apple Card "Monthly Activity" proportions
struct WeeklyActivityCard: View {
  let dailyCashAmount: Double
  let daySpending: [DaySpending]

  private var maxTotal: Double {
    daySpending.map(\.total).max() ?? 1
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Weekly Activity")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("+\(dailyCashAmount.formatted(.currency(code: "USD"))) Daily Cash")
          .font(.caption)
          .foregroundStyle(.green)
      }

      Spacer()

      // Stacked bars - 7 days
      HStack(alignment: .bottom, spacing: 3) {
        ForEach(daySpending.prefix(7)) { day in
          StackedBar(
            categoryAmounts: day.categoryAmounts,
            maxTotal: maxTotal,
            maxHeight: 36
          )
        }
      }
    }
    .padding(14)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.clear)
        .glassEffect(.regular)
    }
  }
}

/// Savings account row - matches Apple Card style exactly
struct SavingsAccountRow: View {
  let balance: String

  var body: some View {
    HStack(spacing: 12) {
      RoundedRectangle(cornerRadius: 10)
        .fill(
          LinearGradient(
            colors: [.cyan, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: "building.columns.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
        }

      VStack(alignment: .leading, spacing: 2) {
        Text("Savings Account")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("Current Balance: \(balance)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.quaternary)
    }
    .padding(14)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.clear)
        .glassEffect(.regular)
    }
  }
}

#Preview {
  ScrollView {
    VStack(spacing: 12) {
      AppleCardView(categoryBreakdown: CategorySpending.generateMockData())

      RemainingBalanceCard(remaining: 3500, total: 5000)

      WeeklyActivityCard(
        dailyCashAmount: 15.00,
        daySpending: [45.0, 80.0, 35.0, 120.0, 55.0, 70.0, 90.0].enumerated().map { index, total in
          let perCategory = total / 3.0
          return DaySpending(
            dayIndex: index,
            categoryAmounts: [
              (.shopping, perCategory),
              (.foodAndDrinks, perCategory),
              (.services, perCategory),
            ]
          )
        }
      )

      SavingsAccountRow(balance: "$10,300.00")
    }
    .padding(.horizontal, 20)
  }
  .background(Color(.systemGroupedBackground))
}
