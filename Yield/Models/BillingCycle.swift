//
//  BillingCycle.swift
//  Yield
//
//  Created on 1/20/26.
//

import Foundation

/// Billing frequency for subscriptions
enum BillingCycle: String, Codable, CaseIterable, Sendable {
  case weekly = "weekly"
  case monthly = "monthly"
  case yearly = "yearly"

  /// Human-readable display name
  var displayName: String {
    switch self {
    case .weekly: "Weekly"
    case .monthly: "Monthly"
    case .yearly: "Yearly"
    }
  }

  /// Short display name for compact UI
  var shortName: String {
    switch self {
    case .weekly: "wk"
    case .monthly: "mo"
    case .yearly: "yr"
    }
  }

  /// Number of days in the billing cycle (approximate)
  var daysInCycle: Int {
    switch self {
    case .weekly: 7
    case .monthly: 30
    case .yearly: 365
    }
  }

  /// Calculate next billing date from a given date
  func nextBillingDate(from date: Date) -> Date {
    let calendar = Calendar.current
    switch self {
    case .weekly:
      return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
    case .monthly:
      return calendar.date(byAdding: .month, value: 1, to: date) ?? date
    case .yearly:
      return calendar.date(byAdding: .year, value: 1, to: date) ?? date
    }
  }

  /// Calculate monthly equivalent cost
  func monthlyEquivalent(amount: Double) -> Double {
    switch self {
    case .weekly: amount * 4.33  // Average weeks per month
    case .monthly: amount
    case .yearly: amount / 12
    }
  }

  /// Calculate yearly equivalent cost
  func yearlyEquivalent(amount: Double) -> Double {
    switch self {
    case .weekly: amount * 52
    case .monthly: amount * 12
    case .yearly: amount
    }
  }
}
