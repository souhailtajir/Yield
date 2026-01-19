//
//  SpendingDetailView.swift
//  Yield
//
//  Created on 1/9/26.
//

import Charts
import SwiftUI

/// Time period for spending view
enum SpendingPeriod: String, CaseIterable {
  case week = "Week"
  case month = "Month"
  case year = "Year"
}

/// Breakdown type for spending view
enum SpendingBreakdownType: String, CaseIterable {
  case category = "By Category"
  case merchant = "By Merchant"
}

/// Detailed spending view matching Apple Card UI exactly
struct SpendingDetailView: View {
  @State private var selectedPeriod: SpendingPeriod = .month
  @State private var selectedBreakdown: SpendingBreakdownType = .category

  // Data
  @State private var spendingData: [SpendingDataPoint] = []
  @State private var categoryData: [CategorySpending] = []

  /// Current month/year title
  private var periodTitle: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: Date())
  }

  /// Total spending amount
  private var totalSpending: Double {
    spendingData.reduce(0) { $0 + $1.amount }
  }

  /// Spending comparison (mock)
  private var spendingDifference: Double {
    -28.05
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        // Month Title
        Text(periodTitle)
          .font(.largeTitle)
          .fontWeight(.bold)

        // Spending Summary Section
        spendingSummarySection

        // Category/Merchant Segmented Picker
        breakdownPicker
          .padding(.top, 4)

        // Category Breakdown List
        categoryListSection
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 40)
    }
    .background(Color(.systemGroupedBackground))
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker("Period", selection: $selectedPeriod) {
          ForEach(SpendingPeriod.allCases, id: \.self) { period in
            Text(period.rawValue).tag(period)
          }
        }
        .pickerStyle(.segmented)
        .glassEffect(.regular)
        .frame(minWidth: 220)
      }
    }
    .toolbarTitleDisplayMode(.inline)
    .onAppear {
      loadData()
    }
  }

  // MARK: - Subviews

  /// Category / Merchant segmented picker with glass effect
  private var breakdownPicker: some View {
    Picker("Breakdown", selection: $selectedBreakdown) {
      ForEach(SpendingBreakdownType.allCases, id: \.self) { type in
        Text(type.rawValue).tag(type)
      }
    }
    .pickerStyle(.segmented)
    .glassEffect(.regular)
  }

  /// Spending summary with chart
  private var spendingSummarySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Total Spending header
      Text("Total Spending")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      // Amount with indicator
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Text(totalSpending.formatted(.currency(code: "USD")))
          .font(.system(size: 32, weight: .bold, design: .rounded))

        Image(
          systemName: spendingDifference < 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        )
        .foregroundStyle(spendingDifference < 0 ? .green : .red)
      }

      // Comparison message
      Text(comparisonMessage)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)

      // Bar Chart
      SpendingBarChart(dataPoints: spendingData)
        .frame(height: 180)
        .padding(.top, 8)
    }
    .padding(20)
    .glassEffect(.regular, in: .rect(cornerRadius: 16))
  }

  /// Comparison message text
  private var comparisonMessage: String {
    let absAmount = abs(spendingDifference).formatted(.currency(code: "USD"))
    if spendingDifference < 0 {
      return "So far, you've spent \(absAmount) less than last month at this time."
    } else {
      return "So far, you've spent \(absAmount) more than last month at this time."
    }
  }

  /// Category breakdown list with section header matching DashboardView style
  private var categoryListSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Section header matching Dashboard's "Latest Transactions" style
      HStack {
        Text(selectedBreakdown == .category ? "Spending by Category" : "Spending by Merchant")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        Button {
          // Filter action
        } label: {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 4)

      // Category list with glass effect
      VStack(spacing: 0) {
        ForEach(categoryData) { category in
          CategoryListRow(spending: category)

          if category.id != categoryData.last?.id {
            Divider()
              .padding(.leading, 72)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  // MARK: - Data

  private func loadData() {
    spendingData = SpendingDataPoint.generateMockData()
    categoryData = CategorySpending.generateMockData()
  }
}

/// Bar chart matching Apple Card exactly - purple/orange gradient
struct SpendingBarChart: View {
  let dataPoints: [SpendingDataPoint]

  private var maxAmount: Double {
    dataPoints.map(\.amount).max() ?? 1000
  }

  /// Y-axis values
  private var yAxisValues: [Double] {
    let max = maxAmount
    return [0, max / 3, max * 2 / 3, max]
  }

  var body: some View {
    Chart(dataPoints) { point in
      BarMark(
        x: .value("Week", point.weekRange),
        y: .value("Amount", point.amount)
      )
      .foregroundStyle(
        LinearGradient(
          colors: [
            Color(red: 0.58, green: 0.39, blue: 0.76),  // Purple #9563C2
            Color(red: 1.0, green: 0.72, blue: 0.27),  // Orange/Gold #FFB845
          ],
          startPoint: .bottom,
          endPoint: .top
        )
      )
      .cornerRadius(4)
    }
    .chartXAxis {
      AxisMarks { value in
        AxisValueLabel {
          if let week = value.as(String.self) {
            Text(week)
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .chartYAxis {
      AxisMarks(position: .trailing, values: yAxisValues) { value in
        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
          .foregroundStyle(.secondary.opacity(0.2))
        AxisValueLabel {
          if let amount = value.as(Double.self) {
            Text("$\(Int(amount))")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .chartYScale(domain: 0...(maxAmount * 1.1))
  }
}

/// Single category row matching Apple Card UI
struct CategoryListRow: View {
  let spending: CategorySpending

  var body: some View {
    HStack(spacing: 14) {
      // Category icon in colored rounded rect
      RoundedRectangle(cornerRadius: 10)
        .fill(spending.category.color)
        .frame(width: 44, height: 44)
        .overlay {
          Image(systemName: spending.category.symbol)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Name and transaction count
      VStack(alignment: .leading, spacing: 2) {
        Text(spending.category.displayName)
          .font(.body)
          .foregroundStyle(.primary)

        Text("\(spending.transactionCount) Transaction\(spending.transactionCount == 1 ? "" : "s")")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      // Amount and change
      VStack(alignment: .trailing, spacing: 2) {
        Text(spending.amount.formatted(.currency(code: "USD")))
          .font(.body)
          .foregroundStyle(.primary)

        if spending.changeAmount != 0 {
          HStack(spacing: 2) {
            Image(systemName: spending.changeAmount > 0 ? "arrow.up" : "arrow.down")
              .font(.caption2)
            Text(abs(spending.changeAmount).formatted(.currency(code: "USD")))
              .font(.caption)
          }
          .foregroundStyle(spending.changeAmount < 0 ? .green : .secondary)
        }
      }

      // Chevron
      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .contentShape(Rectangle())
  }
}

#Preview {
  NavigationStack {
    SpendingDetailView()
  }
}
