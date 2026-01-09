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
        amount: 1063.56,
        transactionCount: 9,
        changeAmount: 510.35
      ),
      CategorySpending(
        category: .services,
        amount: 277.92,
        transactionCount: 3,
        changeAmount: 113.17
      ),
      CategorySpending(
        category: .foodAndDrinks,
        amount: 190.14,
        transactionCount: 13,
        changeAmount: 91.36
      ),
      CategorySpending(
        category: .transportation,
        amount: 86.50,
        transactionCount: 12,
        changeAmount: -88.06
      ),
      CategorySpending(
        category: .entertainment,
        amount: 34.94,
        transactionCount: 3,
        changeAmount: 9.00
      ),
      CategorySpending(
        category: .other,
        amount: 26.38,
        transactionCount: 1,
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
