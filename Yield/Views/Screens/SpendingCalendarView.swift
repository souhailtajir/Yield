//
//  SpendingCalendarView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

/// Calendar view showing spending by day - Apple Card style
struct SpendingCalendarView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \YieldTransaction.date, order: .reverse) private var transactions: [YieldTransaction]
  @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]

  @State private var displayedMonth: Date = .now
  @State private var selectedDate: Date?
  @State private var showDayDetail = false

  private let calendar = Calendar.current
  private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

  /// Days in the displayed month
  private var daysInMonth: [Date] {
    guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
      let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
      let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
    else {
      return []
    }

    var dates: [Date] = []
    var current = monthFirstWeek.start

    while current < monthLastWeek.end {
      dates.append(current)
      current = calendar.date(byAdding: .day, value: 1, to: current)!
    }

    return dates
  }

  /// Month/year title
  private var monthTitle: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: displayedMonth)
  }

  /// Total spending for displayed month
  private var monthlyTotal: Double {
    transactions
      .filter { isDateInDisplayedMonth($0.date) && !$0.isCredit }
      .reduce(0) { $0 + $1.amount }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Month summary card
          monthlySummaryCard

          // Calendar grid
          calendarGrid

          // Selected day transactions
          if let selected = selectedDate {
            selectedDaySection(for: selected)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Calendar")
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack(spacing: 16) {
            Button {
              withAnimation {
                goToPreviousMonth()
              }
            } label: {
              Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
            }

            Text(monthTitle)
              .font(.headline)
              .frame(minWidth: 150)

            Button {
              withAnimation {
                goToNextMonth()
              }
            } label: {
              Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
            }
          }
          .foregroundStyle(.primary)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            withAnimation {
              displayedMonth = .now
              selectedDate = nil
            }
          } label: {
            Text("Today")
              .font(.subheadline)
          }
        }
      }
      .sheet(isPresented: $showDayDetail) {
        if let selected = selectedDate {
          DayExpenseDetailView(date: selected)
        }
      }
    }
  }

  // MARK: - Subviews

  /// Monthly summary card
  private var monthlySummaryCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Monthly Spending")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(monthlyTotal.formatted(.currency(code: "USD")))
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)

      // Upcoming subscriptions this month
      let upcomingCount = subscriptionsThisMonth.count
      if upcomingCount > 0 {
        Text("\(upcomingCount) subscription payment\(upcomingCount == 1 ? "" : "s") this month")
          .font(.caption)
          .foregroundStyle(.orange)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .glassEffect(.clear, in: .rect(cornerRadius: 12))
  }

  /// Calendar grid
  private var calendarGrid: some View {
    VStack(spacing: 8) {
      // Weekday headers
      HStack(spacing: 0) {
        ForEach(weekdaySymbols, id: \.self) { symbol in
          Text(symbol)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 8)

      // Days grid
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4)
      {
        ForEach(daysInMonth, id: \.self) { date in
          let dayData = dataForDate(date)

          CalendarDayCell(
            day: calendar.component(.day, from: date),
            isCurrentMonth: isDateInDisplayedMonth(date),
            isToday: calendar.isDateInToday(date),
            isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
            totalSpending: dayData.totalSpending,
            hasSubscriptionPayment: dayData.hasSubscription,
            categoryColors: dayData.categoryColors
          )
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
              if selectedDate.map({ calendar.isDate($0, inSameDayAs: date) }) ?? false {
                showDayDetail = true
              } else {
                selectedDate = date
              }
            }
          }
        }
      }
      .padding(12)
    }
    .glassEffect(.clear, in: .rect(cornerRadius: 16))
  }

  /// Selected day transactions section
  private func selectedDaySection(for date: Date) -> some View {
    let dayTransactions = transactionsForDate(date)
    let daySubscriptions = subscriptionsForDate(date)

    return VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(formattedSelectedDate(date))
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)

        Spacer()

        if !dayTransactions.isEmpty || !daySubscriptions.isEmpty {
          Button {
            showDayDetail = true
          } label: {
            Text("See All")
              .font(.subheadline)
              .foregroundStyle(Color.accentColor)
          }
        }
      }
      .padding(.horizontal, 4)

      if dayTransactions.isEmpty && daySubscriptions.isEmpty {
        Text("No transactions on this day")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 20)
          .glassEffect(.clear, in: .rect(cornerRadius: 12))
      } else {
        VStack(spacing: 0) {
          // Subscription payments
          ForEach(daySubscriptions, id: \.id) { subscription in
            SubscriptionPaymentRow(subscription: subscription)

            if subscription.id != daySubscriptions.last?.id || !dayTransactions.isEmpty {
              Divider()
                .padding(.leading, 72)
            }
          }

          // Transactions
          ForEach(dayTransactions.prefix(3), id: \.id) { transaction in
            TransactionRowView(transaction: transaction)

            if transaction.id != dayTransactions.prefix(3).last?.id {
              Divider()
                .padding(.leading, 68)
            }
          }
        }
        .glassEffect(.clear, in: .rect(cornerRadius: 12))
      }
    }
  }

  // MARK: - Helpers

  private func goToPreviousMonth() {
    if let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
      displayedMonth = newDate
      selectedDate = nil
    }
  }

  private func goToNextMonth() {
    if let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
      displayedMonth = newDate
      selectedDate = nil
    }
  }

  private func isDateInDisplayedMonth(_ date: Date) -> Bool {
    calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
  }

  private func transactionsForDate(_ date: Date) -> [YieldTransaction] {
    transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
  }

  private func subscriptionsForDate(_ date: Date) -> [Subscription] {
    subscriptions.filter {
      $0.isActive && calendar.isDate($0.nextBillingDate, inSameDayAs: date)
    }
  }

  private var subscriptionsThisMonth: [Subscription] {
    subscriptions.filter {
      $0.isActive && isDateInDisplayedMonth($0.nextBillingDate)
    }
  }

  private func dataForDate(_ date: Date) -> (
    totalSpending: Double, hasSubscription: Bool, categoryColors: [Color]
  ) {
    let dayTransactions = transactionsForDate(date).filter { !$0.isCredit }
    let total = dayTransactions.reduce(0) { $0 + $1.amount }
    let hasSubscription = !subscriptionsForDate(date).isEmpty
    let colors = Array(Set(dayTransactions.map { $0.category.color })).prefix(3).map { $0 }

    return (total, hasSubscription, Array(colors))
  }

  private func formattedSelectedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: date)
  }
}

/// Row for subscription payment in calendar
struct SubscriptionPaymentRow: View {
  let subscription: Subscription

  var body: some View {
    HStack(spacing: 14) {
      // Icon with subscription indicator
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(subscription.category.color)
          .frame(width: 44, height: 44)

        Image(systemName: subscription.category.symbol)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(.white)

        // Recurring indicator
        Circle()
          .fill(Color.orange)
          .frame(width: 12, height: 12)
          .overlay {
            Image(systemName: "arrow.clockwise")
              .font(.system(size: 6, weight: .bold))
              .foregroundStyle(.white)
          }
          .offset(x: 16, y: -16)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(subscription.name)
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.primary)

        Text("Subscription")
          .font(.caption)
          .foregroundStyle(.orange)
      }

      Spacer()

      Text(subscription.amount.formatted(.currency(code: "USD")))
        .font(.body)
        .foregroundStyle(.primary)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
  }
}

#Preview {
  SpendingCalendarView()
    .modelContainer(
      for: [YieldTransaction.self, Subscription.self, Portfolio.self], inMemory: true)
}
