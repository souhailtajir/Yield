//
//  SubscriptionRowView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftUI

/// Reusable subscription row component - Apple Card style
struct SubscriptionRowView: View {
  let subscription: Subscription

  var body: some View {
    HStack(spacing: 14) {
      // Category icon in colored rounded rect
      RoundedRectangle(cornerRadius: 10)
        .fill(subscription.category.color)
        .frame(width: 44, height: 44)
        .overlay {
          Image(systemName: iconName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Name and billing info
      VStack(alignment: .leading, spacing: 2) {
        Text(subscription.name)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text(nextPaymentText)
          .font(.caption)
          .foregroundStyle(subscription.isDueSoon ? .orange : .secondary)
      }

      Spacer()

      // Amount and cycle
      VStack(alignment: .trailing, spacing: 2) {
        Text(subscription.amount.formatted(.currency(code: "USD")))
          .font(.body)
          .foregroundStyle(.primary)

        Text(subscription.billingCycle.displayName)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      // Chevron
      Image(systemName: "chevron.right")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 14)
    .contentShape(Rectangle())
  }

  // MARK: - Helpers

  private var iconName: String {
    subscription.iconName ?? subscription.category.symbol
  }

  private var nextPaymentText: String {
    if subscription.isOverdue {
      return "Overdue"
    } else if subscription.daysUntilNextPayment == 0 {
      return "Due today"
    } else if subscription.daysUntilNextPayment == 1 {
      return "Due tomorrow"
    } else {
      return "Due in \(subscription.daysUntilNextPayment) days"
    }
  }
}

#Preview {
  VStack(spacing: 0) {
    SubscriptionRowView(
      subscription: Subscription(
        name: "Netflix",
        amount: 15.99,
        category: .entertainment,
        billingCycle: .monthly,
        nextBillingDate: Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now
      )
    )
    Divider()
      .padding(.leading, 72)
    SubscriptionRowView(
      subscription: Subscription(
        name: "iCloud+",
        amount: 2.99,
        category: .services,
        billingCycle: .monthly,
        nextBillingDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
      )
    )
  }
  .glassEffect(.clear, in: .rect(cornerRadius: 12))
  .padding()
  .background(Color(.systemGroupedBackground))
}
