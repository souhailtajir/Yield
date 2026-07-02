//
//  DayExpenseDetailView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

// Detailed view of expenses for a specific day
struct DayExpenseDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  let date: Date

  @Query private var allTransactions: [YieldTransaction]
  @Query private var allSubscriptions: [Subscription]

  private let calendar = Calendar.current

  /// Transactions for the selected date
  private var transactions: [YieldTransaction] {
    allTransactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
  }

  /// Subscriptions due on the selected date
  private var subscriptionsDue: [Subscription] {
    allSubscriptions.filter {
      $0.isActive && calendar.isDate($0.nextBillingDate, inSameDayAs: date)
    }
  }

  /// Total spending for the day
  private var totalSpending: Double {
    let transactionTotal = transactions.filter { !$0.isCredit }.reduce(0) { $0 + $1.amount }
    let subscriptionTotal = subscriptionsDue.reduce(0) { $0 + $1.amount }
    return transactionTotal + subscriptionTotal
  }

  /// Total income for the day
  private var totalIncome: Double {
    transactions.filter { $0.isCredit }.reduce(0) { $0 + $1.amount }
  }

  /// Formatted date title
  private var dateTitle: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d, yyyy"
    return formatter.string(from: date)
  }

  /// Short date for navigation title
  private var shortDateTitle: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: date)
  }

  init(date: Date) {
    self.date = date

    // Configure query to fetch all, we'll filter in computed properties
    _allTransactions = Query(sort: \YieldTransaction.date, order: .reverse)
    _allSubscriptions = Query(sort: \Subscription.nextBillingDate)
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Date header card
          dateHeaderCard

          // Summary stats
          summaryStats

          // Subscription payments section
          if !subscriptionsDue.isEmpty {
            subscriptionsSection
          }

          // Transactions section
          if !transactions.isEmpty {
            transactionsSection
          }

          // Empty state
          if transactions.isEmpty && subscriptionsDue.isEmpty {
            emptyState
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle(shortDateTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }

  // MARK: - Subviews

  /// Date header card
  private var dateHeaderCard: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(dateTitle)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      if calendar.isDateInToday(date) {
        Text("Today")
          .font(.subheadline)
          .foregroundStyle(Color.accentColor)
      } else if calendar.isDateInYesterday(date) {
        Text("Yesterday")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .glassEffect(.regular, in: .rect(cornerRadius: 12))
  }

  /// Summary statistics
  private var summaryStats: some View {
    HStack(spacing: 0) {
      // Spending
      VStack(alignment: .leading, spacing: 4) {
        Text("Spent")
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(totalSpending.formatted(.currency(code: "USD")))
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(totalSpending > 0 ? .primary : .secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Divider()
        .frame(height: 40)

      // Income
      VStack(alignment: .leading, spacing: 4) {
        Text("Income")
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(totalIncome.formatted(.currency(code: "USD")))
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(totalIncome > 0 ? .green : .secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 16)

      Divider()
        .frame(height: 40)

      // Net
      VStack(alignment: .leading, spacing: 4) {
        Text("Net")
          .font(.caption)
          .foregroundStyle(.secondary)

        let net = totalIncome - totalSpending
        Text(net.formatted(.currency(code: "USD")))
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(net >= 0 ? .green : .red)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 16)
    }
    .padding(16)
    .glassEffect(.regular, in: .rect(cornerRadius: 12))
  }

  /// Subscription payments section
  private var subscriptionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Subscription Payments")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        Text("\(subscriptionsDue.count)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(subscriptionsDue, id: \.id) { subscription in
          SubscriptionPaymentRow(subscription: subscription)

          if subscription.id != subscriptionsDue.last?.id {
            Divider()
              .padding(.leading, 72)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  /// Transactions section
  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Transactions")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        Text("\(transactions.count)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
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

  /// Empty state
  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "calendar.badge.checkmark")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)

      Text("No Activity")
        .font(.title3)
        .fontWeight(.semibold)

      Text("No transactions or payments on this day")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(40)
  }
}

#Preview {
  DayExpenseDetailView(date: .now)
    .modelContainer(
      for: [YieldTransaction.self, Subscription.self, Portfolio.self], inMemory: true)
}
