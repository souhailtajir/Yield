//
//  UpcomingBillsCard.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftUI

/// Dashboard card showing upcoming subscription payments
struct UpcomingBillsCard: View {
  let subscriptions: [Subscription]
  let totalMonthly: Double

  /// Upcoming subscriptions sorted by next billing date
  private var upcomingSubscriptions: [Subscription] {
    subscriptions
      .filter { $0.isActive }
      .sorted { $0.nextBillingDate < $1.nextBillingDate }
      .prefix(3)
      .map { $0 }
  }

  /// Total due this week
  private var dueThisWeek: Double {
    subscriptions
      .filter { $0.isActive && $0.daysUntilNextPayment <= 7 }
      .reduce(0) { $0 + $1.amount }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        Text("Upcoming Bills")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        if dueThisWeek > 0 {
          Text("\(dueThisWeek.formatted(.currency(code: "USD"))) this week")
            .font(.caption)
            .foregroundStyle(.orange)
        }
      }

      // Upcoming subscriptions list
      if upcomingSubscriptions.isEmpty {
        Text("No upcoming bills")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 8)
      } else {
        VStack(spacing: 10) {
          ForEach(upcomingSubscriptions, id: \.id) { subscription in
            UpcomingBillRow(subscription: subscription)
          }
        }
      }

      // Monthly total
      HStack {
        Text("Monthly Total")
          .font(.caption)
          .foregroundStyle(.secondary)

        Spacer()

        Text(totalMonthly.formatted(.currency(code: "USD")))
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)
      }
      .padding(.top, 4)
    }
    .padding(16)
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(.clear)
        .glassEffect(.regular)
    }
  }
}

/// Single row for upcoming bill in the card
struct UpcomingBillRow: View {
  let subscription: Subscription

  var body: some View {
    HStack(spacing: 10) {
      // Small category indicator
      RoundedRectangle(cornerRadius: 6)
        .fill(subscription.category.color)
        .frame(width: 28, height: 28)
        .overlay {
          Image(systemName: subscription.category.symbol)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Name
      Text(subscription.name)
        .font(.subheadline)
        .foregroundStyle(.primary)
        .lineLimit(1)

      Spacer()

      // Due date and amount
      VStack(alignment: .trailing, spacing: 1) {
        Text(subscription.amount.formatted(.currency(code: "USD")))
          .font(.subheadline)
          .foregroundStyle(.primary)

        Text(dueDateText)
          .font(.caption2)
          .foregroundStyle(subscription.isDueSoon ? .orange : .secondary)
      }
    }
  }

  private var dueDateText: String {
    if subscription.daysUntilNextPayment == 0 {
      return "Today"
    } else if subscription.daysUntilNextPayment == 1 {
      return "Tomorrow"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM d"
      return formatter.string(from: subscription.nextBillingDate)
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    UpcomingBillsCard(
      subscriptions: Subscription.generateMockData(),
      totalMonthly: 129.90
    )

    UpcomingBillsCard(
      subscriptions: [],
      totalMonthly: 0
    )
  }
  .padding()
  .background(Color(.systemGroupedBackground))
}
