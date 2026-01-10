//
//  TransactionListView.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftUI

/// Transaction list mimicking Apple Card's "Latest Card Transactions" section
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
      // Header with filter button
      HStack {
        Text("Latest Card Transactions")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(.primary)

        Spacer()

        Button {
          // Filter action
        } label: {
          Image(systemName: "line.3.horizontal.decrease.circle")
            .font(.title3)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 4)

      // Grouped transactions
      ForEach(groupedTransactions, id: \.date) { group in
        VStack(alignment: .leading, spacing: 0) {
          // Transaction rows in card container
          VStack(spacing: 0) {
            ForEach(group.transactions, id: \.id) { transaction in
              TransactionRowView(transaction: transaction)

              if transaction.id != group.transactions.last?.id {
                Divider()
                  .padding(.leading, 72)
              }
            }
          }
          .background(Color(.secondarySystemGroupedBackground))
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
