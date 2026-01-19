//
//  CategoryDetailView.swift
//  Yield
//
//  Created on 1/19/26.
//

import SwiftUI

/// View showing all transactions for a specific spending category
struct CategoryDetailView: View {
  let category: TransactionCategory
  let totalAmount: Double
  let transactionCount: Int

  // Mock transactions for this category
  @State private var transactions: [YieldTransaction] = []

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        // Category header card
        categoryHeader

        // Transactions section
        transactionsSection
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 40)
    }
    .background(Color(.systemGroupedBackground))
    .navigationTitle(category.displayName)
    .toolbarTitleDisplayMode(.inline)
    .onAppear {
      loadTransactions()
    }
  }

  // MARK: - Subviews

  private var categoryHeader: some View {
    HStack(spacing: 16) {
      // Category icon
      RoundedRectangle(cornerRadius: 12)
        .fill(category.color)
        .frame(width: 56, height: 56)
        .overlay {
          Image(systemName: category.symbol)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.white)
        }

      VStack(alignment: .leading, spacing: 4) {
        Text(totalAmount.formatted(.currency(code: "USD")))
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)

        Text("\(transactionCount) Transaction\(transactionCount == 1 ? "" : "s")")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding(20)
    .glassEffect(.regular, in: .rect(cornerRadius: 16))
  }

  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Transactions")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(transactions, id: \.id) { transaction in
          NavigationLink {
            TransactionDetailView(transaction: transaction)
          } label: {
            TransactionRowView(transaction: transaction)
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

  // MARK: - Data

  private func loadTransactions() {
    // Generate mock transactions for this category
    transactions = (0..<transactionCount).map { index in
      let merchants = merchantsForCategory(category)
      let merchant = merchants[index % merchants.count]
      let amount = Double.random(in: 5...150)
      let daysAgo = Int.random(in: 0...30)
      let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()

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
      return ["Starbucks", "Chipotle", "Uber Eats", "DoorDash", "Whole Foods"]
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

#Preview {
  NavigationStack {
    CategoryDetailView(
      category: .shopping,
      totalAmount: 500.00,
      transactionCount: 5
    )
  }
}
