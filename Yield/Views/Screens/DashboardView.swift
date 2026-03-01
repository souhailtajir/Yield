//
//  DashboardView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftData
import SwiftUI

/// Main dashboard - matches Apple Card proportions and spacing exactly
struct DashboardView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
  @State private var viewModel = DashboardViewModel()

  @State private var categoryData: [CategorySpending] = []
  @State private var daySpending: [DaySpending] = []
  @State private var showAddTransaction = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 12) {
          // Main gradient card - credit card aspect ratio
          NavigationLink {
            SpendingDetailView()
          } label: {
            AppleCardView(categoryBreakdown: categoryData)
          }
          .buttonStyle(.plain)
          .padding(.bottom, 8)  // Extra space for card glow

          // Remaining balance card
          RemainingBalanceCard(
            remaining: max(0, viewModel.totalBalance - calculateMonthlyExpenses()),
            total: viewModel.totalBalance
          )

          // Weekly Activity
          WeeklyActivityCard(
            dailyCashAmount: viewModel.todayEarnings * 7,
            daySpending: daySpending
          )

          // Savings Account
          SavingsAccountRow(balance: viewModel.formattedBalance)

          // Upcoming Bills
          UpcomingBillsCard(
            subscriptions: subscriptions,
            totalMonthly: subscriptions.filter { $0.isActive }.reduce(0) { $0 + $1.monthlyCost }
          )

          // Latest Transactions
          if !viewModel.transactions.isEmpty {
            transactionsSection
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Yield")
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showAddTransaction = true
          } label: {
            Image(systemName: "plus")
              .foregroundStyle(.primary)
          }
        }

        ToolbarItem(placement: .topBarTrailing) {

          HStack(spacing: 16) {
            Button {
              // Search
            } label: {
              Image(systemName: "magnifyingglass")
                .foregroundStyle(.primary)
            }

            Button {
              // More
            } label: {
              Image(systemName: "ellipsis.circle")
                .foregroundStyle(.primary)
            }
          }
        }
      }
      .sheet(isPresented: $showAddTransaction) {
        AddTransactionView()
      }
      .refreshable {
        await viewModel.loadData(modelContext: modelContext)
        loadMockData()
      }
    }
    .task {
      await viewModel.loadData(modelContext: modelContext)
      loadMockData()
    }
  }

  // MARK: - Helpers

  private func calculateMonthlyExpenses() -> Double {
    viewModel.transactions
      .filter { !$0.isCredit }
      .reduce(0) { $0 + $1.amount }
  }

  // MARK: - Subviews

  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Latest Transactions")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        Button {
          // Filter
        } label: {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(viewModel.transactions.prefix(5), id: \.id) { transaction in
          NavigationLink {
            TransactionDetailView(transaction: transaction)
          } label: {
            TransactionRowView(transaction: transaction)
          }
          .buttonStyle(.plain)

          if transaction.id != viewModel.transactions.prefix(5).last?.id {
            Divider()
              .padding(.leading, 68)
          }
        }
      }
      .glassEffect(.cleae, in: .rect(cornerRadius: 12))
    }
  }

  // MARK: - Data

  private func loadMockData() {
    categoryData = CategorySpending.generateMockData()

    // Use the top 3 categories from the card for consistent colors
    let topCategories = categoryData.prefix(3).map { $0.category }
    let defaultCategories: [TransactionCategory] = [
      .shopping, .services, .foodAndDrinks,
    ]
    let categories = topCategories.isEmpty ? defaultCategories : Array(topCategories)

    // Simple test data with fixed values
    let dailyTotals = [45.0, 80.0, 35.0, 120.0, 55.0, 70.0, 90.0]

    daySpending = dailyTotals.enumerated().map { index, total in
      // Distribute evenly among categories for simple testing
      let perCategory = total / Double(categories.count)
      let amounts = categories.map { category in
        (category: category, amount: perCategory)
      }
      return DaySpending(dayIndex: index, categoryAmounts: amounts)
    }
  }
}

#Preview {
  DashboardView()
    .modelContainer(for: [Portfolio.self, YieldTransaction.self], inMemory: true)
}
