//
//  TransactionCategory.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Transaction category with SF Symbol mapping for Apple Card-style display
/// Colors and categories match Apple Card exactly
enum TransactionCategory: String, Codable, CaseIterable, Sendable {
  case foodAndDrinks
  case entertainment
  case shopping
  case travel
  case health
  case transportation
  case services
  case income
  case savings
  case other

  /// SF Symbol for category icon - matching Apple Card style
  var symbol: String {
    switch self {
    case .foodAndDrinks: "fork.knife"
    case .entertainment: "star.fill"
    case .shopping: "bag.fill"
    case .travel: "airplane"
    case .health: "heart.fill"
    case .transportation: "car.fill"
    case .services: "wrench.and.screwdriver.fill"
    case .income: "arrow.down.circle.fill"
    case .savings: "banknote.fill"
    case .other: "ellipsis.circle.fill"
    }
  }

  /// Category display color - exact Apple Card colors
  var color: Color {
    switch self {
    case .foodAndDrinks: Color(red: 1.0, green: 0.58, blue: 0.0)  // Orange #FF9500
    case .entertainment: Color(red: 1.0, green: 0.18, blue: 0.33)  // Pink #FF2D55
    case .shopping: Color(red: 1.0, green: 0.80, blue: 0.0)  // Yellow/Gold #FFCC00
    case .travel: Color(red: 0.0, green: 0.48, blue: 1.0)  // Blue #007AFF
    case .health: Color(red: 1.0, green: 0.23, blue: 0.19)  // Red #FF3B30
    case .transportation: Color(red: 0.35, green: 0.78, blue: 0.98)  // Teal #5AC8FA
    case .services: Color(red: 1.0, green: 0.58, blue: 0.0)  // Orange #FF9500
    case .income: Color.green
    case .savings: Color.mint
    case .other: Color(red: 0.56, green: 0.56, blue: 0.58)  // Gray #8E8E93
    }
  }

  /// Human-readable display name
  var displayName: String {
    switch self {
    case .foodAndDrinks: "Food & Drinks"
    case .entertainment: "Entertainment"
    case .shopping: "Shopping"
    case .travel: "Travel"
    case .health: "Health"
    case .transportation: "Transportation"
    case .services: "Services"
    case .income: "Income"
    case .savings: "Savings"
    case .other: "Other"
    }
  }

  /// Categories that represent spending (for filtering)
  static var spendingCategories: [TransactionCategory] {
    [
      .foodAndDrinks, .entertainment, .shopping, .travel, .health, .transportation, .services,
      .other,
    ]
  }
}
