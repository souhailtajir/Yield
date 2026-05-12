//
//  TransactionDetailView.swift
//  Yield
//
//  Created on 1/17/26.
//

import SwiftData
import SwiftUI

/// Transaction detail view matching Apple Card style
struct TransactionDetailView: View {
  @Bindable var transaction: YieldTransaction

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Large amount display
        amountHeader

        // Detail card with glass effect
        detailCard

        // Report issue link
        reportIssueLink
      }
      .padding(.horizontal, 20)
      .padding(.top, 40)
    }
    .background(Color(.systemGroupedBackground))
  }

  // MARK: - Amount Header

  private var amountHeader: some View {
    VStack(spacing: 4) {
      Text(transaction.amount.formatted(.currency(code: "USD")))
        .font(.system(size: 48, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)

      Text(transaction.title)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(formattedDateTime)
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 16)
  }

  private var formattedDateTime: String {
    transaction.date.formatted(.dateTime.month().day().year().hour().minute())
  }

  // MARK: - Detail Card

  private var detailCard: some View {
    VStack(spacing: 0) {
      // Status row
      detailRow(label: "Status", value: "Cleared") {
        Text("Card Number")
          .font(.caption)
          .foregroundStyle(.tertiary)
      }

      Divider()
        .padding(.leading, 16)

      // Total row
      detailRow(
        label: "Total",
        value: transaction.amount.formatted(.currency(code: "USD"))
      ) {
        Text("\(dailyCashPercent)% Daily Cash")
          .font(.caption)
          .foregroundStyle(.tertiary)
      }

      Divider()
        .padding(.leading, 16)

      // Statement row
      detailRow(label: "Shown on", value: "") {
        Text(statementName)
          .font(.subheadline)
          .foregroundStyle(.primary)
      }

      Divider()
        .padding(.leading, 16)

      // Category row with picker
      categoryRow
    }
    .glassEffect(.regular, in: .rect(cornerRadius: 12))
  }

  private func detailRow<Content: View>(
    label: String,
    value: String,
    @ViewBuilder trailing: () -> Content
  ) -> some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundStyle(.primary)

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        if !value.isEmpty {
          Text(value)
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
        trailing()
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

  private var categoryRow: some View {
    HStack {
      Text("Category")
        .font(.subheadline)
        .foregroundStyle(.primary)

      Spacer()

      // Selected category display with icon
      Menu {
        ForEach(TransactionCategory.allCases, id: \.self) { category in
          Button {
            transaction.category = category
          } label: {
            Label {
              Text(category.displayName)
            } icon: {
              Image(systemName: category.symbol)
            }
          }
        }
      } label: {
        HStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 6)
            .fill(transaction.category.color)
            .frame(width: 28, height: 28)
            .overlay {
              Image(systemName: transaction.category.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            }

          Text(transaction.category.displayName)
            .font(.subheadline)
            .foregroundStyle(.primary)

          Image(systemName: "chevron.up.chevron.down")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

  // MARK: - Helpers

  private var dailyCashPercent: String {
    transaction.isCredit ? "0" : "2"
  }

  private var statementName: String {
    transaction.title.lowercased().replacingOccurrences(of: " ", with: "") + ".com"
  }

  // MARK: - Report Issue

  private var reportIssueLink: some View {
    Button {
      // Report issue action
    } label: {
      Text("Report an Issue")
        .font(.subheadline)
        .foregroundStyle(.blue)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 4)
    .padding(.top, 8)
  }
}

#Preview {
  NavigationStack {
    TransactionDetailView(
      transaction: YieldTransaction(
        title: "Nintendo",
        amount: 7.13,
        category: .entertainment,
        isCredit: false
      )
    )
  }
}
