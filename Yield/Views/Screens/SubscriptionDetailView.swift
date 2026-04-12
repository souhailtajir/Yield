//
//  SubscriptionDetailView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

/// Detailed subscription view - Apple Card style
struct SubscriptionDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @Bindable var subscription: Subscription

  @State private var showDeleteConfirmation = false
  @State private var isEditing = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // Hero section
          heroSection

          // Details card
          detailsCard

          // Payment history (mock)
          paymentHistorySection

          // Actions
          actionsSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Done") {
            dismiss()
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isEditing = true
          } label: {
            Text("Edit")
          }
        }
      }
      .confirmationDialog(
        "Delete Subscription",
        isPresented: $showDeleteConfirmation,
        titleVisibility: .visible
      ) {
        Button("Delete", role: .destructive) {
          deleteSubscription()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Are you sure you want to delete this subscription? This action cannot be undone.")
      }
      .sheet(isPresented: $isEditing) {
        EditSubscriptionView(subscription: subscription)
      }
    }
  }

  // MARK: - Subviews

  /// Large centered hero section
  private var heroSection: some View {
    VStack(spacing: 12) {
      // Large category icon
      RoundedRectangle(cornerRadius: 20)
        .fill(subscription.category.color)
        .frame(width: 100, height: 100)
        .overlay {
          Image(systemName: subscription.category.symbol)
            .font(.system(size: 44, weight: .semibold))
            .foregroundStyle(.white)
        }

      // Service name
      Text(subscription.name)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      // Amount and cycle
      Text(subscription.formattedAmountWithCycle)
        .font(.title2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 20)
    .padding(.bottom, 10)
  }

  /// Details card
  private var detailsCard: some View {
    VStack(spacing: 0) {
      DetailRow(title: "Billing Cycle", value: subscription.billingCycle.displayName)
      Divider().padding(.leading, 16)

      DetailRow(title: "Next Payment", value: subscription.formattedNextBillingDate)
      Divider().padding(.leading, 16)

      DetailRow(
        title: "Monthly Cost",
        value: subscription.monthlyCost.formatted(.currency(code: "USD"))
      )
      Divider().padding(.leading, 16)

      DetailRow(
        title: "Yearly Cost",
        value: subscription.yearlyCost.formatted(.currency(code: "USD"))
      )
      Divider().padding(.leading, 16)

      DetailRow(title: "Category", value: subscription.category.displayName)

      if let notes = subscription.notes, !notes.isEmpty {
        Divider().padding(.leading, 16)
        DetailRow(title: "Notes", value: notes)
      }
    }
    .glassEffect(.regular, in: .rect(cornerRadius: 12))
  }

  /// Payment history section (mock data)
  private var paymentHistorySection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Payment History")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)

      VStack(spacing: 0) {
        ForEach(generateMockPaymentHistory(), id: \.date) { payment in
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text(payment.formattedDate)
                .font(.body)
                .foregroundStyle(.primary)
              Text("Payment processed")
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(subscription.amount.formatted(.currency(code: "USD")))
              .font(.body)
              .foregroundStyle(.primary)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)

          if payment.date != generateMockPaymentHistory().last?.date {
            Divider()
              .padding(.leading, 16)
          }
        }
      }
      .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
  }

  /// Actions section
  private var actionsSection: some View {
    VStack(spacing: 12) {
      // Toggle active status
      Button {
        subscription.isActive.toggle()
      } label: {
        HStack {
          Image(systemName: subscription.isActive ? "pause.circle.fill" : "play.circle.fill")
            .font(.title3)
          Text(subscription.isActive ? "Pause Subscription" : "Resume Subscription")
            .font(.body)
          Spacer()
        }
        .foregroundStyle(subscription.isActive ? .orange : .green)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
      }
      .buttonStyle(.plain)

      // Delete button
      Button {
        showDeleteConfirmation = true
      } label: {
        HStack {
          Image(systemName: "trash.fill")
            .font(.title3)
          Text("Delete Subscription")
            .font(.body)
          Spacer()
        }
        .foregroundStyle(.red)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
      }
      .buttonStyle(.plain)
    }
  }

  // MARK: - Helpers

  private func generateMockPaymentHistory() -> [PaymentHistoryItem] {
    let calendar = Calendar.current
    var payments: [PaymentHistoryItem] = []

    for i in 1...3 {
      if let date = calendar.date(
        byAdding: subscription.billingCycle == .yearly ? .year : .month,
        value: -i,
        to: subscription.nextBillingDate
      ) {
        payments.append(PaymentHistoryItem(date: date))
      }
    }

    return payments
  }

  private func deleteSubscription() {
    modelContext.delete(subscription)
    dismiss()
  }
}

/// Simple row for detail display
struct DetailRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack {
      Text(title)
        .font(.body)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .font(.body)
        .foregroundStyle(.primary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

/// Mock payment history item
struct PaymentHistoryItem {
  let date: Date

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
}

/// Edit subscription view
struct EditSubscriptionView: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var subscription: Subscription

  @State private var amount: String = ""
  @State private var name: String = ""
  @State private var selectedCategory: TransactionCategory = .services
  @State private var selectedBillingCycle: BillingCycle = .monthly
  @State private var nextBillingDate: Date = .now
  @State private var notes: String = ""

  private var amountValue: Double {
    Double(amount) ?? 0
  }

  private var canSave: Bool {
    amountValue > 0 && !name.isEmpty
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Amount
          VStack(spacing: 8) {
            Text("Amount")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            TextField("0.00", text: $amount)
              .keyboardType(.decimalPad)
              .font(.body)
              .padding(16)
              .background(Color(.secondarySystemGroupedBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          // Name
          VStack(spacing: 8) {
            Text("Service Name")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            TextField("e.g., Netflix", text: $name)
              .font(.body)
              .padding(16)
              .background(Color(.secondarySystemGroupedBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          // Billing cycle
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
            .glassEffect(.clear)
          }

          // Next billing date
          VStack(alignment: .leading, spacing: 8) {
            Text("Next Billing Date")
              .font(.subheadline)
              .foregroundStyle(.secondary)

            DatePicker("", selection: $nextBillingDate, displayedComponents: [.date])
              .datePickerStyle(.compact)
              .labelsHidden()
              .padding(12)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(Color(.secondarySystemGroupedBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          // Notes
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
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Edit Subscription")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            saveChanges()
          }
          .fontWeight(.semibold)
          .disabled(!canSave)
        }
      }
      .onAppear {
        amount = String(format: "%.2f", subscription.amount)
        name = subscription.name
        selectedCategory = subscription.category
        selectedBillingCycle = subscription.billingCycle
        nextBillingDate = subscription.nextBillingDate
        notes = subscription.notes ?? ""
      }
    }
  }

  private func saveChanges() {
    subscription.amount = amountValue
    subscription.name = name
    subscription.category = selectedCategory
    subscription.billingCycle = selectedBillingCycle
    subscription.nextBillingDate = nextBillingDate
    subscription.notes = notes.isEmpty ? nil : notes
    dismiss()
  }
}

#Preview {
  SubscriptionDetailView(
    subscription: Subscription(
      name: "Netflix",
      amount: 15.99,
      category: .entertainment,
      billingCycle: .monthly,
      nextBillingDate: Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now
    )
  )
  .modelContainer(for: Subscription.self, inMemory: true)
}
