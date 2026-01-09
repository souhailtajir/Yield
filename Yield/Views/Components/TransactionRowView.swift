//
//  TransactionRowView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Single transaction row mimicking Apple Wallet style
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
    transaction.date.formatted(date: .abbreviated, time: .omitted)
  }

  var body: some View {
    HStack(spacing: 14) {
      // Category icon in colored rounded rect (Apple style)
      RoundedRectangle(cornerRadius: 8)
        .fill(transaction.category.color)
        .frame(width: 40, height: 40)
        .overlay {
          Image(systemName: transaction.category.symbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Title and date
      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.title)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text(formattedDate)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      // Amount
      Text(formattedAmount)
        .font(.body)
        .fontWeight(.medium)
        .foregroundStyle(amountColor)

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

#Preview {
  VStack(spacing: 0) {
    TransactionRowView(
      transaction: YieldTransaction(
        title: "Starbucks",
        amount: 6.45,
        category: .foodAndDrinks,
        isCredit: false
      )
    )

    Divider()
      .padding(.leading, 60)

    TransactionRowView(
      transaction: YieldTransaction(
        title: "Paycheck",
        amount: 3500.00,
        category: .income,
        isCredit: true
      )
    )
  }
  .background(Color(.systemBackground))
  .clipShape(RoundedRectangle(cornerRadius: 12))
  .padding()
}
