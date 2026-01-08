//
//  Portfolio.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation
import SwiftData

/// SwiftData model representing the user's investment portfolio
@Model
final class Portfolio: @unchecked Sendable {
  var id: UUID
  var name: String
  var balance: Double
  var yieldPercentage: Double
  var createdAt: Date
  var lastUpdated: Date

  /// Relationship to transactions
  @Relationship(deleteRule: .cascade, inverse: \YieldTransaction.portfolio)
  var transactions: [YieldTransaction]

  /// Yield history for charting (stored as JSON data)
  var yieldHistoryData: Data?

  /// Computed yield history from JSON
  var yieldHistory: [YieldDataPoint] {
    get {
      guard let data = yieldHistoryData else { return [] }
      return (try? JSONDecoder().decode([YieldDataPoint].self, from: data)) ?? []
    }
    set {
      yieldHistoryData = try? JSONEncoder().encode(newValue)
    }
  }

  /// Formatted balance string
  var formattedBalance: String {
    balance.formatted(.currency(code: "USD"))
  }

  /// Formatted yield percentage
  var formattedYield: String {
    yieldPercentage.formatted(.percent.precision(.fractionLength(2)))
  }

  init(
    id: UUID = UUID(),
    name: String = "My Portfolio",
    balance: Double = 0,
    yieldPercentage: Double = 0,
    transactions: [YieldTransaction] = []
  ) {
    self.id = id
    self.name = name
    self.balance = balance
    self.yieldPercentage = yieldPercentage
    self.createdAt = .now
    self.lastUpdated = .now
    self.transactions = transactions
  }
}
