//
//  CategoryDetailView.swift
//  Yield
//
//  Created on 1/19/26.
//

import SwiftUI

/// View showing all transactions for a specific spending category - Apple Card style
struct CategoryDetailView: View {
  let category: TransactionCategory
  let totalAmount: Double
  let transactionCount: Int

  // Mock transactions for this category
  @State private var transactions: [YieldTransaction] = []

  /// Actual count based on loaded transactions
  private var actualCount: Int {
    transactions.count
  }

  /// Date range for summary
  private var dateRangeText: String {
    guard let firstDate = transactions.map(\.date).min(),
      let lastDate = transactions.map(\.date).max()
    else {
      return "This Month"
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d"
    let startText = formatter.string(from: firstDate)

    formatter.dateFormat = "d"
    let endText = formatter.string(from: lastDate)

    return "\(startText)–\(endText)"
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Large centered category icon and title
        categoryHeroSection

        // Transactions section
        transactionsSection
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .padding(.bottom, 120)  // Extra padding for bottom card
    }
    .background(Color(.systemGroupedBackground))
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom) {
      summaryCard
    }
    .onAppear {
      loadTransactions()
    }
  }

  // MARK: - Subviews

  /// Large centered category icon and title - Apple Card style
  private var categoryHeroSection: some View {
    VStack(spacing: 12) {
      // Large category icon
      RoundedRectangle(cornerRadius: 20)
        .fill(category.color)
        .frame(width: 100, height: 100)
        .overlay {
          Image(systemName: category.symbol)
            .font(.system(size: 44, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Category name
      Text(category.displayName)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      // Transaction count
      Text("\(actualCount) Transaction\(actualCount == 1 ? "" : "s")")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 20)
    .padding(.bottom, 10)
  }

  /// Transactions list section
  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Transactions")
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(transactions, id: \.id) { transaction in
          NavigationLink {
            TransactionDetailView(transaction: transaction)
          } label: {
            CategoryTransactionRow(transaction: transaction)
          }
          .buttonStyle(.plain)

          if transaction.id != transactions.last?.id {
            Divider()
              .padding(.leading, 68)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  /// Bottom summary card showing date range and total - fixed to bottom of screen
  private var summaryCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(totalAmount.formatted(.currency(code: "USD")))
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .glassEffect(.clear, in: .rect(cornerRadius: 16))
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
  }

  // MARK: - Data

  private func loadTransactions() {
    // Generate mock transactions for this category
    transactions = (0..<transactionCount).map { index in
      let merchants = merchantsForCategory(category)
      let merchant = merchants[index % merchants.count]
      let amount = Double.random(in: 5...200)
      let hoursAgo = Int.random(in: 1...168)  // Up to 1 week
      let date =
        Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: Date()) ?? Date()

      return YieldTransaction(
        title: merchant,
        amount: amount,
        date: date,
        category: category,
        isCredit: false
      )
    }.sorted { $0.date > $1.date }
  }

  private func merchantsForCategory(_ category: TransactionCategory) -> [String] {
    switch category {
    case .shopping:
      return ["Amazon", "Target", "Walmart", "Best Buy", "Apple Store"]
    case .foodAndDrinks:
      return ["One Shot Cafe", "The Farmer's Dog", "Ashton Cigar Bar", "Starbucks", "Chipotle"]
    case .services:
      return ["Netflix", "Spotify", "iCloud", "Adobe", "Dropbox"]
    case .transportation:
      return ["Uber", "Lyft", "Shell", "Chevron", "Parking"]
    case .entertainment:
      return ["AMC Theaters", "Steam", "Nintendo", "PlayStation", "Apple Arcade"]
    case .health:
      return ["CVS Pharmacy", "Walgreens", "Planet Fitness", "Doctor Visit", "Dental Care"]
    case .travel:
      return ["Delta Airlines", "Marriott", "Airbnb", "United Airlines", "Hilton"]
    case .other:
      return ["Miscellaneous", "Other Store", "Unknown Merchant"]
    case .income, .savings:
      return ["Payment", "Deposit", "Transfer"]
    }
  }
}

/// Transaction row matching Apple Card category detail style
struct CategoryTransactionRow: View {
  let transaction: YieldTransaction

  /// Relative time description
  private var timeAgoText: String {
    let now = Date()
    let components = Calendar.current.dateComponents(
      [.hour, .day], from: transaction.date, to: now)

    if let hours = components.hour, hours < 24 {
      return "\(hours) hour\(hours == 1 ? "" : "s") ago"
    } else if let days = components.day {
      if days == 0 {
        return "Today"
      } else if days == 1 {
        return "Yesterday"
      } else if days < 7 {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Day name
        return formatter.string(from: transaction.date)
      } else {
        return "\(days) days ago"
      }
    }
    return "Recently"
  }

  /// Status text (mock)
  private var statusText: String {
    let statuses = ["Pending - Philadelphia, PA", "Card Number Used", "Completed"]
    return statuses.randomElement() ?? "Completed"
  }

  var body: some View {
    HStack(spacing: 12) {
      // Category icon
      RoundedRectangle(cornerRadius: 10)
        .fill(transaction.category.color)
        .frame(width: 44, height: 44)
        .overlay {
          Image(systemName: transaction.category.symbol)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Merchant info
      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.title)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("Pending")
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(timeAgoText)
          .font(.caption)
          .foregroundStyle(.tertiary)
      }

      Spacer()

      // Amount and cashback
      VStack(alignment: .trailing, spacing: 2) {
        HStack(spacing: 4) {
          Text(transaction.amount.formatted(.currency(code: "USD")))
            .font(.body)
            .foregroundStyle(.primary)

          Image(systemName: "chevron.right")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.quaternary)
        }

        Text("\(Int.random(in: 1...3))%")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
  }
}

#Preview {
  NavigationStack {
    CategoryDetailView(
      category: .shopping,
      totalAmount: 286.71,
      transactionCount: 4
    )
  }
}
