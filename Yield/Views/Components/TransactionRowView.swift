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
    transaction.isCredit ? "+" : "-"
  }

  private var formattedAmount: String {
    amountPrefix + transaction.amount.formatted(.currency(code: "USD"))
  }

  private var formattedDate: String {
    transaction.date.formatted(date: .abbreviated, time: .omitted)
  }

  var body: some View {
    HStack(spacing: 14) {
      // Category icon
      ZStack {
        Circle()
          .fill(transaction.category.color.opacity(0.15))
          .frame(width: 44, height: 44)

        Image(systemName: transaction.category.symbol)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(transaction.category.color)
      }

      // Title and date
      VStack(alignment: .leading, spacing: 3) {
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
        .fontWeight(.semibold)
        .foregroundStyle(amountColor)
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 16)
    .background {
      RoundedRectangle(cornerRadius: 14)
        .fill(.ultraThinMaterial)
    }
    .glassEffect(.clear)
  }
}

#Preview {
  VStack(spacing: 8) {
    TransactionRowView(
      transaction: YieldTransaction(
        title: "Starbucks",
        amount: 6.45,
        category: .dining,
        isCredit: false
      )
    )

    TransactionRowView(
      transaction: YieldTransaction(
        title: "Paycheck",
        amount: 3500.00,
        category: .income,
        isCredit: true
      )
    )
  }
  .padding()
  .walletBackground()
}
