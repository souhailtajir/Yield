//
//  Subscription.swift
//  Yield
//
//  Created on 1/20/26.
//

import Foundation
import SwiftData

/// SwiftData model representing a recurring subscription
@Model
final class Subscription {
  var id: UUID
  var name: String
  var amount: Double
  var categoryRaw: String
  var billingCycleRaw: String
  var nextBillingDate: Date
  var startDate: Date
  var isActive: Bool
  var notes: String?
  var iconName: String?

  /// Computed category from raw string
  var category: TransactionCategory {
    get { TransactionCategory(rawValue: categoryRaw) ?? .services }
    set { categoryRaw = newValue.rawValue }
  }

  /// Computed billing cycle from raw string
  var billingCycle: BillingCycle {
    get { BillingCycle(rawValue: billingCycleRaw) ?? .monthly }
    set { billingCycleRaw = newValue.rawValue }
  }

  /// Monthly equivalent cost
  var monthlyCost: Double {
    billingCycle.monthlyEquivalent(amount: amount)
  }

  /// Yearly equivalent cost
  var yearlyCost: Double {
    billingCycle.yearlyEquivalent(amount: amount)
  }

  /// Days until next payment
  var daysUntilNextPayment: Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: .now, to: nextBillingDate)
    return max(0, components.day ?? 0)
  }

  /// Whether payment is due soon (within 7 days)
  var isDueSoon: Bool {
    daysUntilNextPayment <= 7
  }

  /// Whether payment is overdue
  var isOverdue: Bool {
    nextBillingDate < .now
  }

  /// Formatted amount with billing cycle
  var formattedAmountWithCycle: String {
    "\(amount.formatted(.currency(code: "USD")))/\(billingCycle.shortName)"
  }

  /// Formatted next billing date
  var formattedNextBillingDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: nextBillingDate)
  }

  /// Update to next billing date after a payment
  func advanceToNextBillingDate() {
    nextBillingDate = billingCycle.nextBillingDate(from: nextBillingDate)
  }

  init(
    id: UUID = UUID(),
    name: String,
    amount: Double,
    category: TransactionCategory = .services,
    billingCycle: BillingCycle = .monthly,
    nextBillingDate: Date = .now,
    startDate: Date = .now,
    isActive: Bool = true,
    notes: String? = nil,
    iconName: String? = nil
  ) {
    self.id = id
    self.name = name
    self.amount = amount
    self.categoryRaw = category.rawValue
    self.billingCycleRaw = billingCycle.rawValue
    self.nextBillingDate = nextBillingDate
    self.startDate = startDate
    self.isActive = isActive
    self.notes = notes
    self.iconName = iconName
  }
}

// MARK: - Mock Data

extension Subscription {
  /// Generate sample subscriptions for previews
  static func generateMockData() -> [Subscription] {
    let calendar = Calendar.current

    return [
      Subscription(
        name: "Netflix",
        amount: 15.99,
        category: .entertainment,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 5, to: .now) ?? .now
      ),
      Subscription(
        name: "Spotify",
        amount: 10.99,
        category: .entertainment,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 12, to: .now) ?? .now
      ),
      Subscription(
        name: "iCloud+",
        amount: 2.99,
        category: .services,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 3, to: .now) ?? .now
      ),
      Subscription(
        name: "Adobe Creative Cloud",
        amount: 54.99,
        category: .services,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 18, to: .now) ?? .now
      ),
      Subscription(
        name: "Planet Fitness",
        amount: 24.99,
        category: .health,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 7, to: .now) ?? .now
      ),
      Subscription(
        name: "Apple One",
        amount: 19.95,
        category: .services,
        billingCycle: .monthly,
        nextBillingDate: calendar.date(byAdding: .day, value: 21, to: .now) ?? .now
      ),
    ]
  }
}
