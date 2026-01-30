//
//  CategoryBreakdownView.swift
//  Yield
//
//  Created on 1/9/26.
//

import SwiftUI

/// Data model for category spending breakdown
struct CategorySpending: Identifiable {
  let id = UUID()
  let category: TransactionCategory
  let amount: Double
  let transactionCount: Int
  let changeAmount: Double  // Positive = up, negative = down
}

/// Category breakdown list matching Apple Wallet spending by category
struct CategoryBreakdownView: View {
  let categories: [CategorySpending]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(categories) { category in
        CategoryRow(spending: category)

        if category.id != categories.last?.id {
          Divider()
            .padding(.leading, 60)
        }
      }
    }
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

/// Single row in category breakdown
struct CategoryRow: View {
  let spending: CategorySpending

  private var changeIndicator: some View {
    Group {
      if spending.changeAmount > 0 {
        HStack(spacing: 2) {
          Image(systemName: "arrow.up")
            .font(.caption2)
          Text(spending.changeAmount.formatted(.currency(code: "USD")))
            .font(.caption)
        }
        .foregroundStyle(.secondary)
      } else if spending.changeAmount < 0 {
        HStack(spacing: 2) {
          Image(systemName: "arrow.down")
            .font(.caption2)
          Text(abs(spending.changeAmount).formatted(.currency(code: "USD")))
            .font(.caption)
        }
        .foregroundStyle(.green)
      }
    }
  }

  var body: some View {
    HStack(spacing: 14) {
      // Category icon in colored rounded rect (Apple style)
      RoundedRectangle(cornerRadius: 8)
        .fill(spending.category.color)
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: spending.category.symbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Category name and transaction count
      VStack(alignment: .leading, spacing: 2) {
        Text(spending.category.displayName)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("\(spending.transactionCount) Transaction\(spending.transactionCount == 1 ? "" : "s")")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      // Amount and change
      VStack(alignment: .trailing, spacing: 2) {
        Text(spending.amount.formatted(.currency(code: "USD")))
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        changeIndicator
      }

      // Chevron
      Image(systemName: "chevron.right")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
  }
}

/// Generate mock category spending data
extension CategorySpending {
  static func generateMockData() -> [CategorySpending] {
    [
      CategorySpending(
        category: .shopping,
        amount: 1432.00,
        transactionCount: 5,
        changeAmount: 50.00
      ),
      CategorySpending(
        category: .foodAndDrinks,
        amount: 300.00,
        transactionCount: 8,
        changeAmount: 25.00
      ),
      CategorySpending(
        category: .services,
        amount: 150.00,
        transactionCount: 2,
        changeAmount: -10.00
      ),
      CategorySpending(
        category: .transportation,
        amount: 75.00,
        transactionCount: 4,
        changeAmount: 5.00
      ),
      CategorySpending(
        category: .entertainment,
        amount: 50.00,
        transactionCount: 2,
        changeAmount: 0
      ),
    ]
  }
}

#Preview {
  ScrollView {
    CategoryBreakdownView(categories: CategorySpending.generateMockData())
      .padding()
  }
}
