//
//  DashboardViewModel.swift
//  Yield
//
//  Created on 1/8/26.
//

import Foundation
import Observation
import SwiftData

/// Main dashboard view model with @Observable and @MainActor isolation
@MainActor
@Observable
final class DashboardViewModel {
  // MARK: - Published State

  var portfolio: Portfolio?
  var transactions: [YieldTransaction] = []
  var yieldDataPoints: [YieldDataPoint] = []
  var isLoading = false
  var errorMessage: String?
  var showChart = false

  // MARK: - Computed Properties

  var currentYieldPercentage: Double {
    portfolio?.yieldPercentage ?? 0.0485
  }

  var totalBalance: Double {
    portfolio?.balance ?? 0
  }

  var formattedBalance: String {
    totalBalance.formatted(.currency(code: "USD"))
  }

  var formattedYield: String {
    currentYieldPercentage.formatted(.percent.precision(.fractionLength(2)))
  }

  var todayEarnings: Double {
    yieldDataPoints.last?.yieldValue ?? 0
  }

  // MARK: - Data Loading

  /// Load all dashboard data using TaskGroup for parallel fetching
  func loadData(modelContext: ModelContext) async {
    isLoading = true
    errorMessage = nil

    await withTaskGroup(of: Void.self) { group in
      // Fetch portfolio
      group.addTask { @MainActor in
        await self.fetchPortfolio(modelContext: modelContext)
      }

      // Fetch transactions
      group.addTask { @MainActor in
        await self.fetchTransactions(modelContext: modelContext)
      }

      // Generate yield history
      group.addTask { @MainActor in
        await self.generateYieldHistory()
      }
    }

    isLoading = false
  }

  /// Fetch portfolio from SwiftData or create default
  private func fetchPortfolio(modelContext: ModelContext) async {
    let descriptor = FetchDescriptor<Portfolio>()

    do {
      let portfolios = try modelContext.fetch(descriptor)
      if let existing = portfolios.first {
        portfolio = existing
      } else {
        // Create default portfolio with mock data
        let newPortfolio = MockDataGenerator.generatePortfolio()
        modelContext.insert(newPortfolio)
        portfolio = newPortfolio
      }
    } catch {
      errorMessage = "Failed to fetch portfolio: \(error.localizedDescription)"
    }
  }

  /// Fetch transactions from SwiftData or generate mock data
  private func fetchTransactions(modelContext: ModelContext) async {
    let descriptor = FetchDescriptor<YieldTransaction>(
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )

    do {
      let fetched = try modelContext.fetch(descriptor)
      if fetched.isEmpty {
        // Generate mock transactions
        let mockTransactions = MockDataGenerator.generateTransactions(count: 15)
        for transaction in mockTransactions {
          modelContext.insert(transaction)
        }
        transactions = mockTransactions
      } else {
        transactions = fetched
      }
    } catch {
      errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
    }
  }

  /// Generate yield history using YieldActor
  private func generateYieldHistory() async {
    let balance = portfolio?.balance ?? 24_567.89
    let rate = portfolio?.yieldPercentage ?? 0.0485

    // Use YieldActor for off-main-thread calculation
    let points = await YieldActor.shared.generateYieldHistory(
      startingBalance: balance,
      annualRate: rate,
      days: 30
    )

    yieldDataPoints = points
  }

  /// Calculate current yield using YieldActor
  func calculateCurrentYield() async -> Double {
    guard let portfolio else { return 0 }

    return await YieldActor.shared.calculateYield(
      principal: portfolio.balance,
      rate: portfolio.yieldPercentage,
      days: 1
    )
  }

  // MARK: - Actions

  func toggleChart() {
    showChart.toggle()
  }
}
