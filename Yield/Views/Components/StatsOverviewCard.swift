//
//  StatsOverviewCard.swift
//  Yield
//
//  Created on 1/9/26.
//

import Charts
import SwiftUI

/// Stats overview widget matching Apple Wallet style - tappable to show detail
struct StatsOverviewCard: View {
  let totalBalance: Double
  let monthlyChange: Double
  let sparklineData: [Double]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Top row - icon and mini sparkline
      HStack(alignment: .top) {
        // App icon with gradient
        RoundedRectangle(cornerRadius: 12)
          .fill(
            LinearGradient(
              colors: [
                Color(red: 0.58, green: 0.39, blue: 0.76),  // Purple
                Color(red: 1.0, green: 0.72, blue: 0.27),  // Orange
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 50, height: 50)
          .overlay {
            Image(systemName: "chart.line.uptrend.xyaxis")
              .font(.system(size: 22, weight: .semibold))
              .foregroundStyle(.white)
          }

        Spacer()

        // Mini sparkline
        if !sparklineData.isEmpty {
          MiniSparklineChart(data: sparklineData)
            .frame(width: 100, height: 50)
        }
      }

      Spacer()

      // Balance section
      VStack(alignment: .leading, spacing: 4) {
        Text("Total Balance")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(totalBalance.formatted(.currency(code: "USD")))
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)

          // Change indicator
          if monthlyChange != 0 {
            HStack(spacing: 2) {
              Image(systemName: monthlyChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption.weight(.semibold))
              Text(monthlyChange >= 0 ? "+\(Int(monthlyChange))" : "\(Int(monthlyChange))")
                .font(.caption.weight(.semibold))
            }
            .foregroundStyle(monthlyChange >= 0 ? .green : .red)
          }
        }
      }
    }
    .padding(20)
    .frame(height: 180)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

/// Mini sparkline chart
struct MiniSparklineChart: View {
  let data: [Double]

  private var dataPoints: [(index: Int, value: Double)] {
    data.enumerated().map { (index: $0.offset, value: $0.element) }
  }

  var body: some View {
    Chart(dataPoints, id: \.index) { point in
      LineMark(
        x: .value("Day", point.index),
        y: .value("Value", point.value)
      )
      .foregroundStyle(
        LinearGradient(
          colors: [
            Color(red: 0.58, green: 0.39, blue: 0.76),
            Color(red: 1.0, green: 0.72, blue: 0.27),
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .interpolationMethod(.catmullRom)

      AreaMark(
        x: .value("Day", point.index),
        y: .value("Value", point.value)
      )
      .foregroundStyle(
        LinearGradient(
          colors: [
            Color(red: 0.58, green: 0.39, blue: 0.76).opacity(0.3),
            Color.clear,
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .interpolationMethod(.catmullRom)
    }
    .chartXAxis(.hidden)
    .chartYAxis(.hidden)
  }
}

/// Data for a single day's stacked category spending
struct DaySpending: Identifiable {
  let id = UUID()
  let dayIndex: Int
  let categoryAmounts: [(category: TransactionCategory, amount: Double)]

  var total: Double {
    categoryAmounts.reduce(0) { $0 + $1.amount }
  }
}

/// Weekly activity stacked bar chart matching Apple Card exactly
struct WeeklyActivityBars: View {
  let daySpending: [DaySpending]

  private var maxTotal: Double {
    daySpending.map(\.total).max() ?? 1
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 3) {
      ForEach(daySpending) { day in
        StackedBar(
          categoryAmounts: day.categoryAmounts,
          maxTotal: maxTotal,
          maxHeight: 28
        )
      }
    }
  }
}

/// Single stacked bar with category colors
struct StackedBar: View {
  let categoryAmounts: [(category: TransactionCategory, amount: Double)]
  let maxTotal: Double
  let maxHeight: CGFloat

  private var totalAmount: Double {
    categoryAmounts.reduce(0) { $0 + $1.amount }
  }

  private var normalizedHeight: CGFloat {
    totalAmount > 0 ? max(6, CGFloat(totalAmount / maxTotal) * maxHeight) : 6
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(categoryAmounts.enumerated()), id: \.offset) { _, item in
        let segmentHeight =
          totalAmount > 0
          ? (item.amount / totalAmount) * normalizedHeight
          : 0

        Rectangle()
          .fill(item.category.color)
          .frame(width: 8, height: max(0, segmentHeight))
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 2))
  }
}

/// Two-column quick stats row
struct QuickStatsRow: View {
  let leftTitle: String
  let leftValue: String
  let leftSubtitle: String?
  let rightTitle: String
  let rightValue: String
  let rightSubtitle: String?

  var body: some View {
    HStack(spacing: 16) {
      // Left stat
      VStack(alignment: .leading, spacing: 4) {
        Text(leftTitle)
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(leftValue)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.primary)

        if let subtitle = leftSubtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Divider()
        .frame(height: 50)

      // Right stat
      VStack(alignment: .leading, spacing: 4) {
        Text(rightTitle)
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(rightValue)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.primary)

        if let subtitle = rightSubtitle {
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

/// Weekly activity section with stacked category bars - Apple Card style
struct WeeklyActivitySection: View {
  let weeklyTotal: Double
  let dailyAmounts: [Double]

  /// Generate stacked spending data from daily amounts
  private var daySpending: [DaySpending] {
    let categories: [TransactionCategory] = [
      .foodAndDrinks, .entertainment, .shopping, .transportation, .services,
    ]

    return dailyAmounts.prefix(7).enumerated().map { index, total in
      // Distribute total among random categories
      var remaining = total
      var amounts: [(category: TransactionCategory, amount: Double)] = []

      for (i, category) in categories.enumerated() {
        if i == categories.count - 1 {
          amounts.append((category, remaining))
        } else {
          let portion = Double.random(in: 0...(remaining * 0.6))
          amounts.append((category, portion))
          remaining -= portion
        }
      }

      return DaySpending(dayIndex: index, categoryAmounts: amounts.filter { $0.amount > 0 })
    }
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Weekly Activity")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("+\(weeklyTotal.formatted(.currency(code: "USD"))) Daily Cash")
          .font(.caption)
          .foregroundStyle(.green)
      }

      Spacer()

      WeeklyActivityBars(daySpending: daySpending)
    }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  VStack(spacing: 16) {
    StatsOverviewCard(
      totalBalance: 24567.89,
      monthlyChange: 1234,
      sparklineData: [100, 120, 110, 140, 130, 160, 155, 170, 180, 175, 190, 200]
    )

    QuickStatsRow(
      leftTitle: "Monthly Savings",
      leftValue: "$1,234.56",
      leftSubtitle: "APY: 4.85%",
      rightTitle: "This Month",
      rightValue: "$456.78",
      rightSubtitle: nil
    )

    WeeklyActivitySection(
      weeklyTotal: 15.43,
      dailyAmounts: [50, 80, 30, 120, 90, 60, 100]
    )
  }
  .padding()
  .background(Color(.systemGroupedBackground))
}
