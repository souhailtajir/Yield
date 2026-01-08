//
//  YieldActor.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation

/// Global actor for handling high-frequency yield calculations off the main thread
@globalActor
actor YieldActor {
  static let shared = YieldActor()

  private init() {}

  /// Calculate simple yield
  func calculateYield(principal: Double, rate: Double, days: Int) -> Double {
    let dailyRate = rate / 365.0
    return principal * dailyRate * Double(days)
  }

  /// Calculate compound interest
  func computeCompoundInterest(
    principal: Double,
    annualRate: Double,
    compoundingFrequency: Int = 12,
    years: Double
  ) -> Double {
    let n = Double(compoundingFrequency)
    let r = annualRate
    let t = years
    return principal * pow(1 + r / n, n * t)
  }

  /// Generate yield history data points for charting
  func generateYieldHistory(
    startingBalance: Double,
    annualRate: Double,
    days: Int
  ) -> [YieldDataPoint] {
    var points: [YieldDataPoint] = []
    let calendar = Calendar.current
    let today = Date()

    for day in 0..<days {
      guard let date = calendar.date(byAdding: .day, value: -days + day, to: today) else {
        continue
      }

      // Simulate some variance in yield
      let variance = Double.random(in: -0.002...0.002)
      let effectiveRate = annualRate + variance
      let daysElapsed = Double(day + 1)
      let yieldValue = startingBalance * (effectiveRate / 365.0) * daysElapsed

      points.append(YieldDataPoint(date: date, yieldValue: yieldValue))
    }

    return points
  }

  /// Calculate current APY based on yield history
  func calculateAPY(yieldHistory: [YieldDataPoint], principal: Double) -> Double {
    guard let firstPoint = yieldHistory.first,
      let lastPoint = yieldHistory.last,
      principal > 0
    else { return 0 }

    let totalYield = lastPoint.yieldValue - firstPoint.yieldValue
    let daysDiff =
      Calendar.current.dateComponents([.day], from: firstPoint.date, to: lastPoint.date).day ?? 1

    guard daysDiff > 0 else { return 0 }

    let dailyRate = totalYield / principal / Double(daysDiff)
    return dailyRate * 365.0
  }
}
