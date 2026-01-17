//
//  TransactionRowView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Transaction row matching Apple Card "Latest Card Transactions" style exactly
struct TransactionRowView: View {
  let transaction: YieldTransaction

  private var amountColor: Color {
    transaction.isCredit ? .green : .primary
  }

  private var amountPrefix: String {
    transaction.isCredit ? "+" : ""
  }

  private var formattedAmount: String {
    amountPrefix + transaction.amount.formatted(.currency(code: "USD"))
  }

  private var formattedDate: String {
    transaction.date.formatted(.dateTime.month().day().year())
  }

  var body: some View {
    HStack(spacing: 12) {
      // Category icon - 40x40 rounded rect
      RoundedRectangle(cornerRadius: 10)
        .fill(transaction.category.color)
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: transaction.category.symbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Title, category, date
      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text(transaction.category.displayName)
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(formattedDate)
          .font(.caption)
          .foregroundStyle(.tertiary)
      }

      Spacer()

      // Amount and cashback
      VStack(alignment: .trailing, spacing: 2) {
        Text(formattedAmount)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(amountColor)

        if !transaction.isCredit {
          Text("2%")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      // Chevron
      Image(systemName: "chevron.right")
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.quaternary)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .contentShape(Rectangle())
  }
}

#Preview {
  VStack(spacing: 0) {
    TransactionRowView(
      transaction: YieldTransaction(
        title: "CVS Pharmacy",
        amount: 286.45,
        category: .health,
        isCredit: false
      )
    )

    Divider()
      .padding(.leading, 68)

    TransactionRowView(
      transaction: YieldTransaction(
        title: "Lyft",
        amount: 46.28,
        category: .transportation,
        isCredit: false
      )
    )

    Divider()
      .padding(.leading, 68)

    TransactionRowView(
      transaction: YieldTransaction(
        title: "Payment",
        amount: 311.37,
        category: .income,
        isCredit: true,
        notes: "From Apple Cash"
      )
    )
  }
  .background(Color(.secondarySystemGroupedBackground))
  .clipShape(RoundedRectangle(cornerRadius: 12))
  .padding(.horizontal, 20)
  .background(Color(.systemGroupedBackground))
}
