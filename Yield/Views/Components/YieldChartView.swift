//
//  YieldChartView.swift
//  Yield
//
//  Created on 1/8/26.
//

import Charts
import SwiftUI

/// Apple Charts view showing yield over time with AreaMark
struct YieldChartView: View {
  let dataPoints: [YieldDataPoint]

  @State private var selectedPoint: YieldDataPoint?

  /// Gradient for the area fill
  private var areaGradient: LinearGradient {
    LinearGradient(
      colors: [
        .green.opacity(0.4),
        .green.opacity(0.1),
        .clear,
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }

  /// Maximum yield value for chart scaling
  private var maxYield: Double {
    dataPoints.map(\.yieldValue).max() ?? 100
  }

  /// Formatted total yield
  private var totalYield: String {
    let total = dataPoints.last?.yieldValue ?? 0
    return total.formatted(.currency(code: "USD"))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Header
      VStack(alignment: .leading, spacing: 4) {
        Text("Yield Over Time")
          .font(.headline)
          .foregroundStyle(.white.opacity(0.7))

        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(totalYield)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.white)

          HStack(spacing: 2) {
            Image(systemName: "arrow.up.right")
              .font(.caption)
            Text("30 days")
              .font(.caption)
          }
          .foregroundStyle(.green)
        }
      }

      // Chart
      Chart(dataPoints) { point in
        // Area fill
        AreaMark(
          x: .value("Date", point.date),
          y: .value("Yield", point.yieldValue)
        )
        .foregroundStyle(areaGradient)
        .interpolationMethod(.catmullRom)

        // Line on top
        LineMark(
          x: .value("Date", point.date),
          y: .value("Yield", point.yieldValue)
        )
        .foregroundStyle(.green)
        .lineStyle(StrokeStyle(lineWidth: 2))
        .interpolationMethod(.catmullRom)

        // Selection point
        if let selected = selectedPoint, selected.id == point.id {
          PointMark(
            x: .value("Date", point.date),
            y: .value("Yield", point.yieldValue)
          )
          .foregroundStyle(.white)
          .symbolSize(80)

          RuleMark(x: .value("Date", point.date))
            .foregroundStyle(.white.opacity(0.3))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
      }
      .chartXAxis {
        AxisMarks(values: .stride(by: .day, count: 7)) { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            .foregroundStyle(.white.opacity(0.1))
          AxisValueLabel {
            if let date = value.as(Date.self) {
              Text(date.formatted(.dateTime.day().month(.abbreviated)))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
            }
          }
        }
      }
      .chartYAxis {
        AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            .foregroundStyle(.white.opacity(0.1))
          AxisValueLabel {
            if let yield = value.as(Double.self) {
              Text("$\(Int(yield))")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
            }
          }
        }
      }
      .chartYScale(domain: 0...(maxYield * 1.1))
      .chartOverlay { proxy in
        GeometryReader { geometry in
          Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  guard let plotFrame = proxy.plotFrame else { return }
                  let x = value.location.x - geometry[plotFrame].origin.x
                  guard let date: Date = proxy.value(atX: x) else { return }

                  selectedPoint = dataPoints.min {
                    abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                  }
                }
                .onEnded { _ in
                  selectedPoint = nil
                }
            )
        }
      }
      .frame(height: 200)
    }
    .padding(20)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(.ultraThinMaterial)
    }
    .glassEffect(.regular)
  }
}

#Preview {
  YieldChartView(
    dataPoints: MockDataGenerator.generateYieldHistory(days: 30)
  )
  .padding()
  .walletBackground()
}
