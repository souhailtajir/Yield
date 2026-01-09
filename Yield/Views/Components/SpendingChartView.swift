//
//  SpendingChartView.swift
//  Yield
//
//  Created on 1/9/26.
//

import Charts
import SwiftUI

/// Data point for spending chart bars
struct SpendingDataPoint: Identifiable {
  let id = UUID()
  let weekRange: String
  let amount: Double
  let startDay: Int
}

/// Bar chart matching Apple Card spending view with purple/orange gradient bars
struct SpendingChartView: View {
  let dataPoints: [SpendingDataPoint]
  let maxAmount: Double

  init(dataPoints: [SpendingDataPoint]) {
    self.dataPoints = dataPoints
    self.maxAmount = dataPoints.map(\.amount).max() ?? 1000
  }

  /// Gradient fill from purple to orange (like Apple Card)
  private var barGradient: LinearGradient {
    LinearGradient(
      colors: [
        Color(red: 0.6, green: 0.4, blue: 0.8),  // Purple
        Color(red: 1.0, green: 0.7, blue: 0.3),  // Orange/Gold
      ],
      startPoint: .bottom,
      endPoint: .top
    )
  }

  /// Y-axis markers based on max amount
  private var yAxisValues: [Double] {
    let step = maxAmount / 3
    return [0, step, step * 2, maxAmount].map { $0.rounded() }
  }

  var body: some View {
    Chart(dataPoints) { point in
      BarMark(
        x: .value("Week", point.weekRange),
        y: .value("Amount", point.amount)
      )
      .foregroundStyle(barGradient)
      .cornerRadius(4)
    }
    .chartXAxis {
      AxisMarks(values: .automatic) { value in
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
          .foregroundStyle(.secondary.opacity(0.3))
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
    .frame(height: 180)
  }
}

/// Generate mock spending data for chart
extension SpendingDataPoint {
  static func generateMockData(for month: Date = Date()) -> [SpendingDataPoint] {
    let calendar = Calendar.current
    let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30

    // Create week ranges
    var points: [SpendingDataPoint] = []
    var startDay = 1

    while startDay <= daysInMonth {
      let endDay = min(startDay + 6, daysInMonth)
      let rangeString = startDay == endDay ? "\(startDay)" : "\(startDay)–\(endDay)"
      let amount = Double.random(in: 50...1200)

      points.append(
        SpendingDataPoint(
          weekRange: rangeString,
          amount: amount,
          startDay: startDay
        ))

      startDay = endDay + 1
    }

    return points
  }
}

#Preview {
  VStack {
    SpendingChartView(dataPoints: SpendingDataPoint.generateMockData())
      .padding()
  }
}
