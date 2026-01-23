//
//  ExpensesView.swift
//  Yield
//
//  Created on 1/23/26.
//

import SwiftData
import SwiftUI

/// Main expenses view - subscriptions as a feature, not the whole tab
struct ExpensesView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
  @Query(sort: \YieldTransaction.date, order: .reverse) private var transactions: [YieldTransaction]

  @State private var showAddTransaction = false
  @State private var categoryData: [CategorySpending] = []

  /// Total monthly expenses from transactions
  private var totalMonthlyExpenses: Double {
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth =
      calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

    return
      transactions
      .filter { $0.date >= startOfMonth && !$0.isCredit }
      .reduce(0) { $0 + $1.amount }
  }

  /// Total monthly subscriptions cost
  private var totalSubscriptionsCost: Double {
    subscriptions
      .filter { $0.isActive }
      .reduce(0) { $0 + $1.monthlyCost }
  }

  /// Combined total monthly spending
  private var totalMonthlySpending: Double {
    totalMonthlyExpenses + totalSubscriptionsCost
  }

  /// Active subscriptions count
  private var activeSubscriptionCount: Int {
    subscriptions.filter { $0.isActive }.count
  }

  /// Upcoming subscriptions (next 3)
  private var upcomingSubscriptions: [Subscription] {
    subscriptions
      .filter { $0.isActive }
      .sorted { $0.nextBillingDate < $1.nextBillingDate }
      .prefix(3)
      .map { $0 }
  }

  /// Recent expenses (non-credit transactions)
  private var recentExpenses: [YieldTransaction] {
    transactions
      .filter { !$0.isCredit }
      .prefix(5)
      .map { $0 }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Summary card
          summaryCard

          // Quick stats row
          quickStatsRow

          // Subscriptions section (condensed)
          subscriptionsSection

          // Recent expenses
          if !recentExpenses.isEmpty {
            recentExpensesSection
          }

          // Category breakdown
          if !categoryData.isEmpty {
            categorySection
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Expenses")
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showAddTransaction = true
          } label: {
            Image(systemName: "plus")
              .foregroundStyle(.primary)
          }
        }
      }
      .sheet(isPresented: $showAddTransaction) {
        AddTransactionView()
      }
    }
    .onAppear {
      loadCategoryData()
      if subscriptions.isEmpty {
        generateMockSubscriptions()
      }
    }
  }

  // MARK: - Subviews

  /// Summary card showing total monthly spending
  private var summaryCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Monthly Expenses")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(totalMonthlySpending.formatted(.currency(code: "USD")))
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)

      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Transactions")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(totalMonthlyExpenses.formatted(.currency(code: "USD")))
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Divider()
          .frame(height: 30)

        VStack(alignment: .leading, spacing: 2) {
          Text("Subscriptions")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(totalSubscriptionsCost.formatted(.currency(code: "USD")))
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Spacer()
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .glassEffect(.regular, in: .rect(cornerRadius: 16))
  }

  /// Quick stats row
  private var quickStatsRow: some View {
    HStack(spacing: 12) {
      StatPill(
        icon: "creditcard.fill",
        value: "\(activeSubscriptionCount)",
        label: "Active Subs"
      )

      StatPill(
        icon: "arrow.down.circle.fill",
        value: "\(transactions.filter { !$0.isCredit }.count)",
        label: "Expenses"
      )

      StatPill(
        icon: "chart.pie.fill",
        value: "\(categoryData.count)",
        label: "Categories"
      )
    }
  }

  /// Condensed subscriptions section
  private var subscriptionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Subscriptions")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        NavigationLink {
          SubscriptionsView()
        } label: {
          Text("View All")
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
        }
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        if upcomingSubscriptions.isEmpty {
          Text("No active subscriptions")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        } else {
          ForEach(upcomingSubscriptions, id: \.id) { subscription in
            NavigationLink {
              SubscriptionDetailView(subscription: subscription)
            } label: {
              SubscriptionRowView(subscription: subscription)
            }
            .buttonStyle(.plain)

            if subscription.id != upcomingSubscriptions.last?.id {
              Divider()
                .padding(.leading, 72)
            }
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  /// Recent expenses section
  private var recentExpensesSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Recent Expenses")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        NavigationLink {
          SpendingDetailView()
        } label: {
          Text("See Details")
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
        }
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(recentExpenses, id: \.id) { transaction in
          NavigationLink {
            TransactionDetailView(transaction: transaction)
          } label: {
            TransactionRowView(transaction: transaction)
          }
          .buttonStyle(.plain)

          if transaction.id != recentExpenses.last?.id {
            Divider()
              .padding(.leading, 68)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  /// Category breakdown section
  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Spending by Category")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        NavigationLink {
          SpendingDetailView()
        } label: {
          Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
        }
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(categoryData.prefix(4)) { category in
          NavigationLink {
            CategoryDetailView(
              category: category.category,
              totalAmount: category.amount,
              transactionCount: category.transactionCount
            )
          } label: {
            CategoryListRow(spending: category)
          }
          .buttonStyle(.plain)

          if category.id != categoryData.prefix(4).last?.id {
            Divider()
              .padding(.leading, 72)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  // MARK: - Data

  private func loadCategoryData() {
    categoryData = CategorySpending.generateMockData()
  }

  private func generateMockSubscriptions() {
    let mockData = Subscription.generateMockData()
    for subscription in mockData {
      modelContext.insert(subscription)
    }
  }
}

/// Small stat pill for quick stats row
struct StatPill: View {
  let icon: String
  let value: String
  let label: String

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.caption)
        .foregroundStyle(.secondary)

      VStack(alignment: .leading, spacing: 0) {
        Text(value)
          .font(.subheadline)
          .fontWeight(.semibold)
        Text(label)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .glassEffect(.regular, in: .capsule)
  }
}

#Preview {
  ExpensesView()
    .modelContainer(for: [Subscription.self, YieldTransaction.self], inMemory: true)
}
