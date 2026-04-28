//
//  AddTransactionView.swift
//  Yield
//
//  Created on 1/9/26
//

import SwiftData
import SwiftUI

/// Transaction type for entry
enum TransactionType: String, CaseIterable {
  case expense = "Expense"
  case income = "Income"
  case savings = "Savings"
}

/// View for adding new transactions (expenses, income, savings)
/// Styled to match Apple Card's transaction detail view
struct AddTransactionView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  // Form state
  @State private var amount: String = ""
  @State private var title: String = ""
  @State private var selectedCategory: TransactionCategory = .foodAndDrinks
  @State private var selectedDate: Date = .now
  @State private var notes: String = ""
  @State private var transactionType: TransactionType = .expense

  @FocusState private var isAmountFocused: Bool

  /// Categories to show based on transaction type
  private var availableCategories: [TransactionCategory] {
    switch transactionType {
    case .expense:
      return TransactionCategory.spendingCategories
    case .income:
      return [.income]
    case .savings:
      return [.savings]
    }
  }

  /// Parsed amount value
  private var amountValue: Double {
    Double(amount) ?? 0
  }

  /// Can save the transaction
  private var canSave: Bool {
    amountValue > 0 && !title.isEmpty
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Amount display
          amountSection

          // Transaction type picker
          transactionTypePicker

          // Title field
          titleField

          // Category picker
          if transactionType == .expense {
            categoryPicker
          }

          // Date picker
          datePicker

          // Notes field
          notesField
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Add Transaction")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            saveTransaction()
          }
          .fontWeight(.semibold)
          .disabled(!canSave)
        }
      }
    }
    .onAppear {
      isAmountFocused = true
    }
  }

  // MARK: - Subviews

  /// Large amount display with currency input
  private var amountSection: some View {
    VStack(spacing: 12) {
      Text("$\(amount.isEmpty ? "0.00" : amount)")
        .font(.system(size: 56, weight: .bold, design: .rounded))
        .foregroundStyle(amountValue > 0 ? .primary : .tertiary)
        .contentTransition(.numericText())
        .animation(.snappy, value: amount)

      TextField("0.00", text: $amount)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.center)
        .font(.title2)
        .focused($isAmountFocused)
        .opacity(0)
        .frame(height: 1)
    }
    .padding(.vertical, 32)
    .frame(maxWidth: .infinity)
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  /// Transaction type segmented control
  private var transactionTypePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Type")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Picker("Type", selection: $transactionType) {
        ForEach(TransactionType.allCases, id: \.self) { type in
          Text(type.rawValue).tag(type)
        }
      }
      .pickerStyle(.segmented)
      .glassEffect(.clear)
    }
  }

  /// Title/merchant text field
  private var titleField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Title")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      TextField("e.g., Starbucks", text: $title)
        .font(.body)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  /// Category picker matching Apple Card style
  private var categoryPicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Category")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Menu {
        ForEach(availableCategories, id: \.self) { category in
          Button {
            selectedCategory = category
          } label: {
            Label(category.displayName, systemImage: category.symbol)
          }
        }
      } label: {
        HStack(spacing: 14) {
          // Category icon
          RoundedRectangle(cornerRadius: 8)
            .fill(selectedCategory.color)
            .frame(width: 40, height: 40)
            .overlay {
              Image(systemName: selectedCategory.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            }

          Text(selectedCategory.displayName)
            .font(.body)
            .foregroundStyle(.primary)

          Spacer()

          Image(systemName: "chevron.up.chevron.down")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
  }

  /// Date picker
  private var datePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Date")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
        .datePickerStyle(.compact)
        .labelsHidden()
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  /// Notes text field
  private var notesField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Notes (Optional)")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      TextField("Add a note...", text: $notes, axis: .vertical)
        .lineLimit(3...6)
        .font(.body)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  // MARK: - Actions

  private func saveTransaction() {
    let category: TransactionCategory
    let isCredit: Bool

    switch transactionType {
    case .expense:
      category = selectedCategory
      isCredit = false
    case .income:
      category = .income
      isCredit = true
    case .savings:
      category = .savings
      isCredit = false
    }

    let transaction = YieldTransaction(
      title: title,
      amount: amountValue,
      date: selectedDate,
      category: category,
      isCredit: isCredit,
      notes: notes.isEmpty ? nil : notes
    )

    modelContext.insert(transaction)
    dismiss()
  }
}

#Preview {
  AddTransactionView()
    .modelContainer(for: YieldTransaction.self, inMemory: true)
}
