//
//  ContentView.swift
//  Yield
//
//  Created on 1/20/26.
//

import SwiftData
import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
  @State private var selectedTab: Tab = .dashboard

  enum Tab: String, CaseIterable {
    case dashboard = "Home"
    case expenses = "Expenses"
    case spendings = "Spendings"

    var icon: String {
      switch self {
      case .dashboard: "dollarsign.bank.building.fill"
      case .expenses: "creditcard.fill"
      case .spendings: "banknote.fill"
      }
    }
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      ForEach(Tab.allCases, id: \.self) { tab in
        tabContent(for: tab)
          .tabItem {
            Label(tab.rawValue, systemImage: tab.icon)
          }
          .tag(tab)
      }
    }
  }

  @ViewBuilder
  private func tabContent(for tab: Tab) -> some View {
    switch tab {
    case .dashboard:
      DashboardView()
    case .expenses:
      SubscriptionsView()
    case .spendings:
      SpendingCalendarView()
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(
      for: [Portfolio.self, YieldTransaction.self, Subscription.self], inMemory: true)
}
