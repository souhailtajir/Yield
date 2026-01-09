//
//  TransactionListView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Transaction list mimicking Apple Wallet's "Latest Transactions" section
struct TransactionListView: View {
  let transactions: [YieldTransaction]

  /// Group transactions by date
  private var groupedTransactions: [(date: Date, transactions: [YieldTransaction])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: transactions) { transaction in
      calendar.startOfDay(for: transaction.date)
    }
    return grouped.map { (date: $0.key, transactions: $0.value) }
      .sorted { $0.date > $1.date }
  }

  /// Format section header date
  private func sectionHeader(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
      return "Today"
    } else if calendar.isDateInYesterday(date) {
      return "Yesterday"
    } else {
      return date.formatted(.dateTime.weekday(.wide).month().day())
    }
  }

  var body: some View {
    LazyVStack(alignment: .leading, spacing: 16) {
      // Header
      HStack {
        Text("Latest Transactions")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(.primary)

        Spacer()

        Button {
          // View all action
        } label: {
          Text("See All")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.blue)
        }
      }
      .padding(.horizontal, 4)

      // Grouped transactions
      ForEach(groupedTransactions, id: \.date) { group in
        VStack(alignment: .leading, spacing: 8) {
          // Date section header
          Text(sectionHeader(for: group.date))
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)

          // Transaction rows
          VStack(spacing: 0) {
            ForEach(group.transactions, id: \.id) { transaction in
              TransactionRowView(transaction: transaction)

              if transaction.id != group.transactions.last?.id {
                Divider()
                  .padding(.leading, 60)
              }
            }
          }
          .background(Color(.systemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }
      }
    }
  }
}

#Preview {
  ScrollView {
    TransactionListView(
      transactions: MockDataGenerator.generateTransactions(count: 10)
    )
    .padding()
  }
  .background(Color(.systemGroupedBackground))
}
