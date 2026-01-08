//
//  TransactionCategory.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Transaction category with SF Symbol mapping for Apple Wallet-style display
enum TransactionCategory: String, Codable, CaseIterable, Sendable {
  case groceries
  case transport
  case entertainment
  case dining
  case shopping
  case utilities
  case health
  case travel
  case income
  case investment
  case other

  /// SF Symbol for category icon
  var symbol: String {
    switch self {
    case .groceries: "cart.fill"
    case .transport: "car.fill"
    case .entertainment: "movieclapper.fill"
    case .dining: "fork.knife"
    case .shopping: "bag.fill"
    case .utilities: "bolt.fill"
    case .health: "heart.fill"
    case .travel: "airplane"
    case .income: "arrow.down.circle.fill"
    case .investment: "chart.line.uptrend.xyaxis"
    case .other: "ellipsis.circle.fill"
    }
  }

  /// Category display color
  var color: Color {
    switch self {
    case .groceries: .green
    case .transport: .blue
    case .entertainment: .purple
    case .dining: .orange
    case .shopping: .pink
    case .utilities: .yellow
    case .health: .red
    case .travel: .cyan
    case .income: .mint
    case .investment: .indigo
    case .other: .gray
    }
  }

  /// Human-readable display name
  var displayName: String {
    rawValue.capitalized
  }
}
