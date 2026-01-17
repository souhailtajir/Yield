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
    case .services: "storefront.fill"  // Store icon like Apple Card
    case .income: "arrow.down.circle.fill"
    case .savings: "building.columns.fill"
    case .other: "building.2.fill"  // Building icon like Apple Card
    }
  }

  /// Category display color - exact Apple Card colors from screenshot
  var color: Color {
    switch self {
    case .foodAndDrinks: Color(red: 0.98, green: 0.60, blue: 0.20)  // Orange
    case .entertainment: Color(red: 0.95, green: 0.55, blue: 0.55)  // Coral/Pink
    case .shopping: Color(red: 0.95, green: 0.78, blue: 0.25)  // Golden Yellow
    case .travel: Color(red: 0.20, green: 0.60, blue: 0.98)  // Blue
    case .health: Color(red: 0.98, green: 0.35, blue: 0.35)  // Red
    case .transportation: Color(red: 0.40, green: 0.65, blue: 0.90)  // Light Blue
    case .services: Color(red: 0.68, green: 0.55, blue: 0.85)  // Purple
    case .income: Color(red: 0.30, green: 0.78, blue: 0.40)  // Green
    case .savings: Color(red: 0.40, green: 0.75, blue: 0.85)  // Teal
    case .other: Color(red: 0.60, green: 0.60, blue: 0.65)  // Gray
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
