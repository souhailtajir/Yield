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
    case dashboard = "Dashboard"
    case subscriptions = "Subscriptions"
    case calendar = "Calendar"

    var icon: String {
      switch self {
      case .dashboard: "creditcard.fill"
      case .subscriptions: "arrow.clockwise.circle.fill"
      case .calendar: "calendar"
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
    case .subscriptions:
      SubscriptionsView()
    case .calendar:
      SpendingCalendarView()
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(
      for: [Portfolio.self, YieldTransaction.self, Subscription.self], inMemory: true)
}
