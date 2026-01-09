//
//  DashboardView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftData
import SwiftUI

/// Main dashboard screen with Apple Wallet-style design - stats focused
struct DashboardView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel = DashboardViewModel()

  // Mock data for display
  @State private var sparklineData: [Double] = []
  @State private var weeklyActivity: [Double] = []
  @State private var categoryData: [CategorySpending] = []

  // Sheet state
  @State private var showAddTransaction = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Stats Overview Card - tappable to show spending detail
          NavigationLink {
            SpendingDetailView()
          } label: {
            StatsOverviewCard(
              totalBalance: viewModel.totalBalance,
              monthlyChange: viewModel.todayEarnings * 30,
              sparklineData: sparklineData
            )
          }
          .buttonStyle(.plain)

          // Quick Stats Row (Savings / Spending)
          QuickStatsRow(
            leftTitle: "Monthly Savings",
            leftValue: viewModel.todayEarnings.formatted(.currency(code: "USD")),
            leftSubtitle: "APY: \(viewModel.formattedYield)",
            rightTitle: "This Month",
            rightValue: (viewModel.todayEarnings * 30).formatted(.currency(code: "USD")),
            rightSubtitle: nil
          )

          // Weekly Activity
          WeeklyActivitySection(
            weeklyTotal: viewModel.todayEarnings * 7,
            dailyAmounts: weeklyActivity
          )

          // Savings Account Row
          savingsAccountRow

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
              // Search action
            } label: {
              Image(systemName: "magnifyingglass")
                .foregroundStyle(.primary)
            }

            Button {
              // More options
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
      .overlay {
        if viewModel.isLoading {
          ProgressView()
            .scaleEffect(1.5)
        }
      }
    }
    .task {
      await viewModel.loadData(modelContext: modelContext)
      loadMockData()
    }
  }

  // MARK: - Subviews

  /// Savings account quick access row
  private var savingsAccountRow: some View {
    HStack(spacing: 12) {
      // Icon
      RoundedRectangle(cornerRadius: 8)
        .fill(
          LinearGradient(
            colors: [.cyan, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: "building.columns.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
        }

      VStack(alignment: .leading, spacing: 2) {
        Text("Savings Account")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("Current Balance: \(viewModel.formattedBalance)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.tertiary)
    }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  /// Latest transactions section
  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Latest Transactions")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(.primary)

        Spacer()
      }

      VStack(spacing: 0) {
        ForEach(viewModel.transactions.prefix(5), id: \.id) { transaction in
          TransactionRowView(transaction: transaction)

          if transaction.id != viewModel.transactions.prefix(5).last?.id {
            Divider()
              .padding(.leading, 60)
          }
        }
      }
      .background(Color(.secondarySystemGroupedBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  // MARK: - Data Loading

  private func loadMockData() {
    // Generate sparkline data
    sparklineData = (0..<14).map { _ in Double.random(in: 100...200) }

    // Generate weekly activity
    weeklyActivity = (0..<7).map { _ in Double.random(in: 20...150) }

    // Generate category data
    categoryData = CategorySpending.generateMockData()
  }
}

#Preview {
  DashboardView()
    .modelContainer(for: [Portfolio.self, YieldTransaction.self], inMemory: true)
}
