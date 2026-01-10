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
          .font(.subheadline)
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
          TransactionRowView(transaction: transaction)

          if transaction.id != viewModel.transactions.prefix(5).last?.id {
            Divider()
              .padding(.leading, 68)
          }
        }
      }
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(.clear)
          .glassEffect(.regular)
      }
    }
  }

  // MARK: - Data

  private func loadMockData() {
    categoryData = CategorySpending.generateMockData()

    let categories: [TransactionCategory] = [
      .foodAndDrinks, .entertainment, .shopping, .transportation, .services,
    ]

    daySpending = (0..<7).map { index in
      let total = Double.random(in: 20...150)
      var remaining = total
      var amounts: [(category: TransactionCategory, amount: Double)] = []

      for (i, category) in categories.enumerated() {
        if i == categories.count - 1 {
          amounts.append((category, remaining))
        } else {
          let portion = Double.random(in: 0...(remaining * 0.6))
          amounts.append((category, portion))
          remaining -= portion
        }
      }

      return DaySpending(dayIndex: index, categoryAmounts: amounts.filter { $0.amount > 0 })
    }
  }
}

#Preview {
  DashboardView()
    .modelContainer(for: [Portfolio.self, YieldTransaction.self], inMemory: true)
}
