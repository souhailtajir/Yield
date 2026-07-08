//
//  AddSubscriptionView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

/// View for adding new subscriptions - Apple Card style
struct AddSubscriptionView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  // Form state
  @State private var amount: String = ""
  @State private var name: String = ""
  @State private var selectedCategory: TransactionCategory = .services
  @State private var selectedBillingCycle: BillingCycle = .monthly
  @State private var nextBillingDate: Date = .now
  @State private var notes: String = ""

  @FocusState private var isAmountFocused: Bool

  /// Parsed amount value
  private var amountValue: Double {
    Double(amount) ?? 0
  }

  /// Can save the subscription
  private var canSave: Bool {
    amountValue > 0 && !name.isEmpty
  }

  /// Monthly equivalent for display
  private var monthlyEquivalent: Double {
    selectedBillingCycle.monthlyEquivalent(amount: amountValue)
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Amount display
          amountSection

          // Name field
          nameField

          // Billing cycle picker
          billingCyclePicker

          // Category picker
          categoryPicker

          // Next billing date
          datePicker

          // Notes field
          notesField
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Add Subscription")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            saveSubscription()
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

      if amountValue > 0 && selectedBillingCycle != .monthly {
        Text("≈ \(monthlyEquivalent.formatted(.currency(code: "USD")))/mo")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

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

  /// Name/service text field
  private var nameField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Service Name")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      TextField("e.g., Netflix", text: $name)
        .font(.body)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  /// Billing cycle segmented control
  private var billingCyclePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Billing Cycle")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Picker("Billing Cycle", selection: $selectedBillingCycle) {
        ForEach(BillingCycle.allCases, id: \.self) { cycle in
          Text(cycle.displayName).tag(cycle)
        }
      }
      .pickerStyle(.segmented)
      .glassEffect()
    }
  }

  /// Category picker matching Apple Card style
  private var categoryPicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Category")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Menu {
        ForEach(TransactionCategory.spendingCategories, id: \.self) { category in
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

  /// Date picker for next billing
  private var datePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Next Billing Date")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      DatePicker("Next Billing Date", selection: $nextBillingDate, displayedComponents: [.date])
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

  private func saveSubscription() {
    let subscription = Subscription(
      name: name,
      amount: amountValue,
      category: selectedCategory,
      billingCycle: selectedBillingCycle,
      nextBillingDate: nextBillingDate,
      notes: notes.isEmpty ? nil : notes
    )

    modelContext.insert(subscription)
    dismiss()
  }
}

#Preview {
  AddSubscriptionView()
    .modelContainer(for: Subscription.self, inMemory: true)
}
