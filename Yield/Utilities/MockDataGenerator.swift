//
//  MockDataGenerator.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation

/// Generates mock data for development and previews
enum MockDataGenerator: Sendable {

  /// Sample transaction titles by category
  private static let transactionTitles: [TransactionCategory: [String]] = [
    .groceries: ["Whole Foods", "Trader Joe's", "Safeway", "Costco"],
    .transport: ["Uber", "Lyft", "Shell Gas", "Chevron"],
    .entertainment: ["Netflix", "Spotify", "AMC Theaters", "Apple TV+"],
    .dining: ["Chipotle", "Starbucks", "The Cheesecake Factory", "In-N-Out"],
    .shopping: ["Amazon", "Target", "Best Buy", "Apple Store"],
    .utilities: ["PG&E", "Comcast", "AT&T", "Water Bill"],
    .health: ["CVS Pharmacy", "Gym Membership", "Doctor Visit", "Walgreens"],
    .travel: ["Delta Airlines", "Marriott Hotel", "Airbnb", "Hertz"],
    .income: ["Paycheck", "Dividend", "Interest Payment", "Bonus"],
    .investment: ["Stock Purchase", "ETF Investment", "Crypto Buy", "Bond Purchase"],
    .other: ["Miscellaneous", "ATM Withdrawal", "Bank Fee", "Transfer"],
  ]

  /// Generate a list of mock transactions
  static func generateTransactions(count: Int = 20) -> [YieldTransaction] {
    var transactions: [YieldTransaction] = []
    let calendar = Calendar.current

    for i in 0..<count {
      let category = TransactionCategory.allCases.randomElement() ?? .other
      let titles = transactionTitles[category] ?? ["Unknown"]
      let title = titles.randomElement() ?? "Transaction"

      let isCredit = category == .income || category == .investment
      let amount =
        isCredit
        ? Double.random(in: 50...5000)
        : Double.random(in: 5...500)

      let daysAgo = Int.random(in: 0...30)
      let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now

      let transaction = YieldTransaction(
        title: title,
        amount: amount,
        date: date,
        category: category,
        isCredit: isCredit
      )
      transactions.append(transaction)
    }

    // Sort by date, newest first
    return transactions.sorted { $0.date > $1.date }
  }

  /// Generate a sample portfolio with transactions and yield history
  static func generatePortfolio() -> Portfolio {
    let portfolio = Portfolio(
      name: "Yield Portfolio",
      balance: 24_567.89,
      yieldPercentage: 0.0485
    )
    return portfolio
  }

  /// Generate yield data points for charting
  static func generateYieldHistory(days: Int = 30) -> [YieldDataPoint] {
    var points: [YieldDataPoint] = []
    let calendar = Calendar.current
    var cumulativeYield = 0.0

    for day in 0..<days {
      guard let date = calendar.date(byAdding: .day, value: -days + day + 1, to: .now) else {
        continue
      }

      // Daily yield with some randomness
      let dailyYield = Double.random(in: 2.5...4.5)
      cumulativeYield += dailyYield

      points.append(YieldDataPoint(date: date, yieldValue: cumulativeYield))
    }

    return points
  }
}
