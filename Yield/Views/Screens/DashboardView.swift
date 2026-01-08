//
//  DashboardView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftData
import SwiftUI

/// Main dashboard screen composing card, chart, and transaction list
struct DashboardView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel = DashboardViewModel()

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Yield Card
          YieldCardView(
            balance: viewModel.formattedBalance,
            yieldPercentage: viewModel.currentYieldPercentage,
            onTap: {
              withAnimation(.spring(duration: 0.4)) {
                viewModel.toggleChart()
              }
            }
          )

          // Expandable Chart
          if viewModel.showChart {
            YieldChartView(dataPoints: viewModel.yieldDataPoints)
              .transition(
                .asymmetric(
                  insertion: .move(edge: .top).combined(with: .opacity),
                  removal: .move(edge: .top).combined(with: .opacity)
                ))
          }

          // Quick Stats Row
          HStack(spacing: 12) {
            StatCard(
              title: "Today's Yield",
              value: viewModel.todayEarnings.formatted(.currency(code: "USD")),
              icon: "chart.line.uptrend.xyaxis",
              color: .green
            )

            StatCard(
              title: "APY",
              value: viewModel.formattedYield,
              icon: "percent",
              color: .blue
            )
          }

          // Transaction List
          TransactionListView(transactions: viewModel.transactions)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .navigationTitle("Yield")
      .navigationBarTitleDisplayMode(.large)
      .toolbarBackground(.hidden, for: .navigationBar)
      .walletBackground()
      .refreshable {
        await viewModel.loadData(modelContext: modelContext)
      }
      .overlay {
        if viewModel.isLoading {
          ProgressView()
            .tint(.white)
            .scaleEffect(1.5)
        }
      }
    }
    .task {
      await viewModel.loadData(modelContext: modelContext)
    }
    .preferredColorScheme(.dark)
  }
}

/// Quick stat card component
struct StatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .font(.subheadline)
          .foregroundStyle(color)

        Spacer()
      }

      Text(value)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(.white)

      Text(title)
        .font(.caption)
        .foregroundStyle(.white.opacity(0.6))
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background {
      RoundedRectangle(cornerRadius: 14)
        .fill(.ultraThinMaterial)
    }
    .glassEffect(.clear)
  }
}

#Preview {
  DashboardView()
    .modelContainer(for: [Portfolio.self, YieldTransaction.self], inMemory: true)
}
