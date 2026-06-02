//
//  SubscriptionsView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

/// Main subscriptions list view - Apple Card style
struct SubscriptionsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]

  @State private var showAddSubscription = false
  @State private var selectedSubscription: Subscription?

  /// Total monthly cost of all active subscriptions
  private var totalMonthlyCost: Double {
    subscriptions
      .filter { $0.isActive }
      .reduce(0) { $0 + $1.monthlyCost }
  }

  /// Total yearly cost of all active subscriptions
  private var totalYearlyCost: Double {
    subscriptions
      .filter { $0.isActive }
      .reduce(0) { $0 + $1.yearlyCost }
  }

  /// Active subscriptions count
  private var activeCount: Int {
    subscriptions.filter { $0.isActive }.count
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Summary card
          summaryCard

          // Subscriptions list
          if subscriptions.isEmpty {
            emptyState
          } else {
            subscriptionsList
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Subscriptions")
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showAddSubscription = true
          } label: {
            Image(systemName: "plus")
              .foregroundStyle(.primary)
          }
        }
      }
      .sheet(isPresented: $showAddSubscription) {
        AddSubscriptionView()
      }
      .sheet(item: $selectedSubscription) { subscription in
        SubscriptionDetailView(subscription: subscription)
      }
    }
    .onAppear {
      // Generate mock data if empty
      if subscriptions.isEmpty {
        generateMockSubscriptions()
      }
    }
  }

  // MARK: - Subviews

  /// Summary card showing total costs
  private var summaryCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Monthly Spending")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(totalMonthlyCost.formatted(.currency(code: "USD")))
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)

      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Yearly")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(totalYearlyCost.formatted(.currency(code: "USD")))
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Divider()
          .frame(height: 30)

        VStack(alignment: .leading, spacing: 2) {
          Text("Active")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(activeCount) subscription\(activeCount == 1 ? "" : "s")")
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Spacer()
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .glassEffect(.clear, in: .rect(cornerRadius: 16))
  }

  /// Empty state view
  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "creditcard.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)

      Text("No Subscriptions")
        .font(.title3)
        .fontWeight(.semibold)

      Text("Track your recurring payments by adding subscriptions")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Button {
        showAddSubscription = true
      } label: {
        Text("Add Subscription")
          .font(.headline)
          .foregroundStyle(.white)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .background(Color.accentColor)
          .clipShape(Capsule())
      }
      .padding(.top, 8)
    }
    .frame(maxWidth: .infinity)
    .padding(40)
  }

  /// Subscriptions list with glass effect
  private var subscriptionsList: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("All Subscriptions")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        Menu {
          Button("Sort by Date") {}
          Button("Sort by Amount") {}
          Button("Sort by Name") {}
        } label: {
          Image(systemName: "arrow.up.arrow.down.circle")
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(subscriptions, id: \.id) { subscription in
          Button {
            selectedSubscription = subscription
          } label: {
            SubscriptionRowView(subscription: subscription)
          }
          .buttonStyle(.plain)

          if subscription.id != subscriptions.last?.id {
            Divider()
              .padding(.leading, 72)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  // MARK: - Actions

  private func generateMockSubscriptions() {
    let mockData = Subscription.generateMockData()
    for subscription in mockData {
      modelContext.insert(subscription)
    }
  }
}

#Preview {
  SubscriptionsView()
    .modelContainer(for: [Subscription.self], inMemory: true)
}
